SETUPLEN=2
SETUPSEG=0x07e0
entry _start
_start:
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#38
    mov bx,#0x0007
    mov bp,#msg1
    mov ax,#0x07c0
    mov es,ax
    mov ax,#0x1301
    int 0x10
load_setup:
    ! 设置驱动器和磁头(drive 0, head 0): 软盘 0 磁头
    mov dx,#0x0000
    ! 设置扇区号和磁道(sector 2, track 0): 0 磁头、0 磁道、2 扇区
    mov cx,#0x0002
    ! 设置扇区号和磁道(sector 2, track 0): 0 磁头、0 磁道、2 扇区
    mov bx,#0x0200
    ! 设置读入的扇区个数(service 2, nr of sectors),
    ! SETUPLEN是读入的扇区个数,Linux 0.11 设置的是 4,
    ! 我们不需要那么多,我们设置为2(因此还需要添加变量 SETUPLEN=2)
    mov ax,#0x0200+SETUPLEN
    ! 应用 0x13 号 BIOS 中断读入 2 个 setup.s扇区
    int 0x13
    ! 读入成功，跳转到 ok_load_setup: ok - continue
    jnc ok_load_setup
    ! 软驱、软盘有问题才会执行到这里。我们的镜像文件比它们可靠多了
    mov dx,#0x0000
    ! 否则复位软驱 reset the diskette
    mov ax,#0x0000
    int 0x13
    ! 重新循环，再次尝试读取
    jmp load_setup
ok_load_setup:
    ! 接下来要干什么？当然是跳到 setup 执行。
    ! 要注意: 我们没有将 bootsect 移到 0x9000,因此跳转后的段地址应该是 0x07e0
    ! 即我们要设置 SETUPSEG=0x07e0
    jmpi    0,SETUPSEG
msg1:
    .byte   13,10
    .ascii  "Hello OS world, this is binarywz"
    .byte   13,10,13,10
.org 510
boot_flag:
    .word   0xAA55