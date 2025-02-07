SETUPLEN  = 4                # setup程序的扇区数
BOOTSEG   = 0x7c0            # 引导扇区加载的段地址
INITSEG   = 0x9000           # 将要移动到的目标段地址
SETUPSEG  = 0x9020           # setup程序的段地址
SYSSEG    = 0x1000           # 系统模块的段地址
ENDSEG    = SYSSEG + SYSSIZE # 系统结束段地址
ROOT_DEV  = 0x000           # 根设备号

.code16                     # 16位代码
.text                       # 代码段开始

.global _start             # 程序入口点
_start:

  jmpl $BOOTSEG, $start2   # 跳转到BOOTSEG:start2

start2:
  # 把引导程序从初始位置(0x7c00)移动到目标位置(0x9000)
  movw $BOOTSEG, %ax       # 设置数据段
  movw %ax, %ds
  movw $INITSEG, %ax       # 设置目标段
  movw %ax, %es
  movw $256, %cx           # 设置移动计数
  subw %si, %si            # 源地址索引清零
  subw %di, %di            # 目标地址索引清零

  rep                      # 重复执行
  movsw                    # 移动一个字

  jmpl $INITSEG, $go      # 跳转到新地址

go:
  # 重新设置段寄存器
  movw %cs, %ax           # 此时 %cs = 0x9000, 先保存在 %ax 中
  movw %ax, %ds
  movw %ax, %es
  movw %ax, %ss
  movw $0xFF00, %sp       # 设置栈指针

load_setup:
  # 从 0 号柱面, 0 号磁头, 第二个扇区开始, 读四个扇区数据进内存
  movw $0x0000, %dx       # dh: 磁头号, dl: 驱动器号
  movw $0x0002, %cx       # ch: 柱面号, cl: 扇区号, 磁道号
  movw $0x0200, %bx       # %es:%bx 指向数据缓冲区
  movb $SETUPLEN, %al     # al: 扇区数
  movb $0x02,   %ah       # 功能号：读扇区到内存
  int  $0x13              # BIOS中断
  jnc  ok_load_setup      # 如果没有出错就跳转
  # 出错时重置磁盘
  movw $0x0000, %dx
  movw $0x0000, %ax
  int  $0x13
  jmp  load_setup         # 重试读取

ok_load_setup:

  movw $msg, %ax          # 显示加载成功消息
  movw %ax, %bp
  movw $0x01301, %ax      # AH=13h AL=01h
  movw $0x0c, %bx         # 页号为0(BH=0)，颜色为红色(BL=0Ch)
  movw $21, %cx           # 字符串长度
  movb $0, %dl            # 行号
  int  $0x010             # 显示中断

  jmpl $SETUPSEG, $0      # 跳转到setup程序

msg:
.ascii "Setup has been loaded"  # 成功消息字符串

.org 508                       # 引导扇区的最后四个字节
root_dev:
  .word ROOT_DEV               # 根设备号
boot_flag:
  .word 0xaa55                # 引导扇区标志
