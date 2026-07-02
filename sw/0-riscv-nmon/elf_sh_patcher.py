import argparse
from elftools.elf.elffile import ELFFile
from capstone import *
from capstone.riscv import *
import os

md = Cs(CS_ARCH_RISCV, CS_MODE_RISCV32)
md.detail = True

#ks = Ks(KS_ARCH_RISCV, KS_MODE_RISCV32)

ASM_TEMPLATE="""
.text
.global patch
{name}:
    {code}
"""

import struct

def encode_jal(rd, pc, target):
    """
    Encode: jal rd, target
    Parameters
    ----------
    rd : int
        Destination register (0-31). Use rd=0 for 'j'.
    pc : int
        Address of the JAL instruction.
    target : int
        Absolute target address.
    Returns
    -------
    int
        32-bit machine instruction.
    """

    offset = target - pc
    # JAL targets must be 2-byte aligned
    if offset & 1:
        raise ValueError("Target is not 2-byte aligned")
    # Range: ±1 MiB
    if offset < -(1 << 20) or offset >= (1 << 20):
        raise ValueError("Target is outside JAL range")
    # Convert to 21-bit two's complement
    imm = offset & 0x1FFFFF
    inst = 0
    # opcode
    inst |= 0x6F
    # rd
    inst |= (rd & 0x1F) << 7
    # imm[19:12]
    inst |= ((imm >> 12) & 0xFF) << 12
    # imm[11]
    inst |= ((imm >> 11) & 0x1) << 20
    # imm[10:1]
    inst |= ((imm >> 1) & 0x3FF) << 21
    # imm[20]
    inst |= ((imm >> 20) & 0x1) << 31
    return inst

def encode_j(rd, pc, target):
    """Returns the instruction bytes in little endian."""
    return struct.pack("<I", encode_jal(rd, pc, target))

def compile_asm(str,cross_compiler):
    os.system("rm patch.S patch.o patch.bin")
    with open("patch.S","w") as f:
        f.write(str)
    os.system(f"{cross_compiler}as -march=rv32e_zicsr -mabi=ilp32e patch.S -o patch.o")
    os.system(f"{cross_compiler}objcopy -O binary patch.o patch.bin")

def main():
    parser = argparse.ArgumentParser(description="nmon ELF loader patcher")
    parser.add_argument("elf")
    parser.add_argument("-c","--cross-compiler", default="riscv64-unknown-elf-")
    parser.add_argument("--verbose", action="store_true")

    args = parser.parse_args()

    with open(args.elf,"rb") as f:
        elf = ELFFile(f)
        patch = elf.get_section_by_name(".patch")
        data = bytearray(patch.data())
        patch_space = patch["sh_addr"]
        patch_offset = patch["sh_offset"]
        print(f"patch_space:{patch_space:08x}",f"patch_offset:{patch_offset:08x}")
        text = elf.get_section_by_name(".text")
        code = bytearray(text.data())
        text_addr = text["sh_addr"]
        text_offset = text["sh_offset"]
        print(f"text_addr:{text_addr:08x}",f"text_offset:{text_offset:08x}")
        idy=0
        insert_addr=patch_space
        read_text=text_addr
        for idx in range(len(code)//4):
            val = struct.unpack("<I",code[idx*4:idx*4+4])[0]
            if val != 0:
                break
            read_text+=4
        for insn in md.disasm(code[read_text:], text_addr+(read_text)):
            if insn.mnemonic == "sh":
                print(hex(insn.address), insn.mnemonic, insn.op_str)
                print(insn.mnemonic, insn.op_str)
                ops=[]
                for i, op in enumerate(insn.operands):
                    #print(f"Operand {i}")
                    if op.type == RISCV_OP_REG:
                        #print("  Register:", insn.reg_name(op.reg))
                        ops.append(insn.reg_name(op.reg))
                    elif op.type == RISCV_OP_IMM:
                        #print("  Immediate:", op.imm)
                        pass
                    elif op.type == RISCV_OP_MEM:
                        #print("  Base:", insn.reg_name(op.mem.base))
                        #print("  Disp:", op.mem.disp)
                        ops.append(op.mem.disp)
                        ops.append(insn.reg_name(op.mem.base))

                file_off = text_offset + (insn.address - text_addr)
                patch_off = patch_offset + (insert_addr-patch_space)

                print(f"file_off {file_off:08x}, text_offset:{text_offset:08x}, text_addr:{text_addr:08x}")
                print(f"patch_off {patch_off:08x}, patch_offset:{patch_offset:08x}, patch_space:{patch_space:08x}")

                code = f"addi sp,sp,-4\n \
                sw {ops[0]},0(sp)\n \
                sb {ops[0]},{ops[1]}({ops[2]})\n \
                srli {ops[0]},{ops[0]},8\n \
                sb {ops[0]}, {(ops[1]+1)}({ops[2]})\n \
                lw {ops[0]},0(sp)\n \
                addi sp,sp,4\n "
                
                if "zero" not in ops[0]:
                    with open(args.elf,"r+b") as file:
                        inst = encode_j(
                        rd=0,
                        pc=int(insn.address),
                        target=int(insert_addr),
                        )             
                        print(inst.hex())
                        file.seek(file_off)
                        file.write(inst)

                    with open(args.elf,"r+b") as file:
                        compile_asm(ASM_TEMPLATE.format(name=f"sh_{idy}",code=code),args.cross_compiler)
                        with open("patch.bin", "rb") as f:
                            replacement = f.read()
                        inst = encode_j(
                        rd=0,
                        pc=int(insert_addr+28),
                        target=int(insn.address+4),
                        )
                        replacement=replacement+inst
                        print(replacement.hex())
                        file.seek(patch_off)
                        file.write(replacement)

                    insert_addr+=32
                    idy+=1
                
                


main()