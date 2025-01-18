BOOTSEG = 0x7c0 # 定义引导扇区的段地址为0x7c0

.code16 # 指定使用16位汇编代码
.text

.global _start
_start:
    jmpl $BOOTSEG, $start2 # 远跳转到BOOTSEG:start2位置

start2 :
    movw $BOOTSEG, %ax # 将BOOTSEG值加载到ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    movw $msg, %ax
    movw %ax, %bp # bp用于指向要显示的字符串
    movw $0x01301, %ax # ah=13h(显示字符串)，al=01h(更新光标位置)
    movw $0x0c, %bx # bh = 0，bl = 0c(红色)
    movw $12, %cx # cx = 串长度
    movb $0, %dl
    int $0x010 # 10h号中断,通知显卡刷新内容

loop:
    jmp loop

msg:
.ascii "Hello World!"

.org 510 # 跳转到第510字节
boot_flag:
    .word 0xaa55 # 引导扇区标志(必须是0xaa55)

# 1. 这是一个典型的引导扇区程序，会被BIOS加载到内存0x7c00处
# 2. 程序首先初始化各个段寄存器
# 3. 然后使用BIOS中断0x10显示一个红色的"Hello World!"字符串
# 4. 显示完后进入无限循环
# 5. 最后两个字节(0xaa55)是引导扇区的标志，BIOS会检查这个标志来确认这是一个有效的引导扇区

# 这是一个最基本的引导扇区程序，展示了如何在实模式下使用 BIOS 中断来显示字符串
# 在操作系统引导过程中，这样的代码通常用于显示初始化信息或错误消息

