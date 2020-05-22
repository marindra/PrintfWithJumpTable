model tiny
.code
org 100h
locals @@

Start:
		push 127
		push '!'
		push 100
		push 3802
		push offset OutLine

		mov di, offset ControlLine
		call printf
		add sp, cx		;
		add sp, cx		;delete our elements

		Ret

OutLine:	db 'love', 0h
ControlLine	db 'I %s %x. %d %%%c %b', 0h
MaxLenOutNumStr	equ 31d
StrForOutNumber	db MaxLenOutNumStr Dup(0), '$'

;-------------------------------------------------
;Enter:		di - address of control line
;		We must put arguments in stack
;		in reverse order
;Return:	cx - count of arguments
;Destroy:	di, ax, bx, cx, dx, si
;-------------------------------------------------
printf		proc

		xor cx, cx
		push bp			;for saving old bp
		mov bp, sp
		dec di

@@start:	inc di
		cmp byte ptr [di], 0h
		jne @@misscom
		jmp @@endofpr
@@misscom:	cmp byte ptr [di], '%'	
		je @@whichchar
		mov dl, byte ptr [di]	;output symbol if it isn't % or 0h
		mov ah, 02h		;
		int 21h			;
		jmp @@start

;-------------------------------------------------
;It decides which symbol is after %. And write if it is %
;Enter:		cx - counter
;		di - pointer of control line
;Destroy:	bx
;-------------------------------------------------
@@whichchar:	inc di
		inc cx
		mov dl, byte ptr [di]
		cmp dl, '%'
		jne @@ItsContrChar	;if it isn't %%
		mov ah, 02h
		int 21h
		dec cx
		jmp @@start

@@ItsContrChar:	lea bx, [@@JumpTable]
		xor dh, dh
		sub dx, 'b'		;symbol a isn't important for us
		shl dx, 1

		add bx, dx		;bx - address in JumpTable of symbol,
					;which was in dl
		mov dx, bx

		mov bx, bp		;
		add bx, cx		;
		add bx, cx		;
		add bx, 4		; bx = bp + 4 + 2 * (cx - 1)
		sub bx, 2		;
		mov ax, word ptr [bx]	; put argument in ax

		jmp dx

;-------------------------------------------------
@@JumpTable:
	jmp short @@BinNum			;'b'
	jmp short @@CharOut			;'c'
	jmp short @@DecNum			;'d'
	jmp short @@start		;'e'
	jmp short @@start		;'f'
	jmp short @@start		;'g'
	jmp short @@start		;'h'
	jmp short @@start		;'i'
	jmp short @@start		;'j'
	jmp short @@start		;'k'
	jmp short @@start		;'l'
	jmp short @@start		;'m'
	jmp short @@start		;'n'
	jmp short @@OxNum			;'o'
	jmp short @@start		;'p'
	jmp short @@start		;'q'
	jmp short @@start		;'r'
	jmp short @@StrOut			;'s'
	jmp short @@start		;'t'
	jmp short @@start		;'u'
	jmp short @@start		;'v'
	jmp short @@start		;'w'
	jmp short @@XecNum			;'x'
;-------------------------------------------------
@@CharOut:	mov dl, al
		mov ah, 02h
		int 21h
		jmp @@start
;-------------------------------------------------
@@StrOut:	mov bx, ax
 @@TmpForStr:	mov dl, byte ptr [bx]
		cmp dl, 0h
		jne @@mcom
		jmp @@start
 @@mcom:	mov ah, 02h
		int 21h
		inc bx
		jmp @@TmpForStr
;-------------------------------------------------
@@BinNum:	mov bx, 2h
		call @@createnum
		jmp @@start 
;-------------------------------------------------
@@DecNum:	mov bx, 10d 
		call @@createnum
		jmp @@start
;-------------------------------------------------
@@OxNum:	mov bx, 8d
		call @@createnum
		jmp @@start
;-------------------------------------------------
@@XecNum:	mov bx, 10h
		call @@createnum
		jmp @@start
;-------------------------------------------------

;-------------------------------------------------
;Enter:		ax - number, which we will write
;		bx - in which system we will write
;			(%b, %o, %x, %d)
;Destroy:	si, dx
;-------------------------------------------------
@@createnum	proc

		mov si, offset StrForOutNumber
		add si, MaxLenOutNumStr
		dec si
		xor dx, dx

 @@hlp:		div bx
		mov byte ptr [si], dl
		xor dx, dx
		dec si
		cmp ax, 0
		jne @@hlp

 @@outnum:	inc si
		mov dl, byte ptr [si]
		mov al, '0'
		mov ah, 02h
		
 @@for:		add dl, '0'
		cmp dl, '9'
		jbe @@next
		add dl, 'A' - '0' - 10d

 @@next:	int 21h
		inc si
		mov dl, byte ptr [si]
		cmp dl, '$'
		jne @@for
@@end:		Ret
		endp



@@endofpr:	pop bp
		Ret
		endp
end Start
