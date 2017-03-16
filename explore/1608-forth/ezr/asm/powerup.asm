; Power-up initialisation code for eZ80

SRAM: equ 0E000h ; starting address of common SRAM
SIZE: equ 00080h ; size of the power-up init code
DEST: equ 0E380h ; load to this address
JUMP: equ 0FA00h ; finish with a jump to this address

BANK: equ 20h	 ; SRAM and MBASE are set to this bank
SAVE: equ 21h	 ; original SRAM contents is this bank

; when booting from flash disk:
;FROM: equ 00h    ; bank from which to copy everything
;FOFF: equ 0000h  ; starting page offset in FROM area

; when booting from RAM disk:
FROM: equ 3Ah	 ; bank from which to copy everything
FOFF: equ 6000h	 ; starting page offset in FROM area

; 1) on power-up, this code initially run at 0000h!
    org DEST

; 2) disable ERAM and move SRAM to BANK
    ld hl,8000h+BANK
    db 0EDh,21h,0B4h ; out0 (RAM_CTL),h ; disable ERAM
    db 0EDh,29h,0B5h ; out0 (RAM_BANK),l ; SRAM to BANK

; 3) copy 8K SRAM {BANK,SRAM} to {SAVE,SRAM}
    db 5Bh,21h ; ld.lil hl,{BANK,SRAM}
    dw SRAM
    db BANK
    db 5Bh,11h ; ld.lil de,{SAVE,SRAM}
    dw SRAM
    db SAVE
    db 5Bh,01h ; ld.lil bc,002000h
    dw 2000h
    db 00h
    db 49h,0EDh,0B0h ; ldir.l

; 4) copy 6.5K {FROM,FOFF} to {BANK,0E380h..0FD80h}
    db 5Bh,21h ; ld.lil hl,{FROM,FOFF}
    dw FOFF
    db FROM
    db 5Bh,11h ; ld.lil de,{BANK,DEST}
    dw DEST
    db BANK
    db 5Bh,01h ; ld.lil bc,2*26*80h
    dw 2*26*80h
    db 00h
    db 49h,0EDh,0B0h ; ldir.l

; 5) jump to SRAM before changing MBASE
    db 5Bh,0C3h ; jp.lil {BANK,reloc1} (enters ADL mode)
    dw reloc1 ; continue running at correct origin
    db BANK
reloc1:

; 6) change MBASE while in ADL mode
    ld a,BANK
    db 0EDh,6Dh ; ld  mb,a
    db 40h,0C3h ; jp.sis reloc2 (this exits ADL mode)
    dw reloc2
reloc2: ; now running in Z80 mode at {BANK,reloc2}

; 7) set up PLL and switch system clock to 50 MHz
    ; TODO ...
    jp JUMP

    ds  DEST+SIZE-$ ; take up slack space
    end