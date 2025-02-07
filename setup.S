.code16
.text
.globl _start_setup

_start_setup:
    movw %cs, %ax          # 将代码段寄存器值保存到ax
    movw %ax, %ds          # 设置数据段寄存器
    movw %ax, %es          # 设置附加段寄存器

    # 显示setup运行消息
    movw $setup_msg, %ax   # 消息字符串地址
    movw %ax, %bp          # ES:BP指向字符串
    movw $0x01301, %ax     # AH=13h显示字符串,AL=01h光标跟随移动
    movw $0x0c, %bx        # 页号为0(BH=0),颜色为红色(BL=0Ch)
    movw $16, %cx          # 字符串长度
    movb $3, %dh           # 行号
    movb $0, %dl           # 列号
    int  $0x010            # BIOS中断显示字符串
setup_msg:
  .ascii "setup is running" # setup运行提示字符串
