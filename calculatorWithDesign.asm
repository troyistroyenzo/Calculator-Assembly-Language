TITLE CALCULATOR
.model medium   
.386
.stack
.data

    dev db ,0ah,0dh,'Developed by:$'

    p1 db 'Enter operand 1:$'
    p2 db 'Enter operand 2:$'
    p3 db 'Enter operator (+,-,*,/):$'   
         
    
    ;--Label
    multiplicated db 'MULTIPLIED!$' 
    subbed db 'SUBTRACTED!$'
    added db 'ADDED!$'
     
	undef db 'UNDEFINED$'
    quotient db 'QUOTIENT:$'
    remainder db 'REMAINDER:$'
    divided db 'DIVIDED!$' 
    
    continue db 'Continue(y/n)?:$'
    
.code                               
m   proc 

;---- Global Variables and Declaration   
    mov ax,@data
    mov ds,ax
    mov ax,0b800h
    mov es,ax
    mov di,7d0h
    mov ah,10100100b
    mov dh,ah

    ;clear screen with color ---pink 
    mov ah,6
    mov al,0
    mov bh,01111111b
    mov ch,0
    mov cl,0
    mov dh,24
    mov dl,80
    int 10h

;-------



  	jmp screen

loopOne: ;--- Get First Operand 
    
	mov ah,2
	mov bh,0
	mov dh,2
	mov dl,25
	int 10h
	
    mov ah,9
    mov dx,offset p1
    int 21h         
    
    mov ah,1
    int 21h    ;ax in hex 
    cmp al,30h ;compare the num  
    
    jae failedFirst
    jmp loopOne

failedFirst:
	
    cmp al,39h 
	jbe passedFirst
	jmp loopOne   
	
passedFirst:
	sub al,30h
	push ax	
	

	
loopTwo: ;--- Get Second Operand
	
	mov ah,2
	mov bh,0
	mov dh,3
	mov dl,25
	int 10h
	
    mov ah,9
    mov dx,offset p2
    int 21h         
    
    mov ah,1
    int 21h ;ax=35  
    
    cmp al,30h
	jae failedSecond
	jmp loopTwo 
	
	
failedSecond:	
    cmp al,39h 

	jbe passedSecond
	jmp loopTwo 
	
passedSecond:
    sub al,30h ; subtract 30 to get 5  
    push ax 
    
    

operator: ;--- Select Operator 
    
    
    mov ah,2
	mov bh,0
	mov dh,4
	mov dl,25
	int 10h
	
	mov ah,09h
    mov dx,offset p3
	int 21h
	mov ah,01h
	int 21h
	mov bl,al
	mov ah,02h
	mov bl,al
	mov ah,02h
	mov dl,0Ah
	int 21h
     
     
    ;--- Directory for the operands
    cmp bl, '*'
	je multiplication
	
	cmp bl, '/'
	je division
	
	cmp bl, '+'
	je addition
	
	cmp bl, '-'
	je subtraction
	
    jmp operator
    
    jmp screen

multiplication:   
    pop bx  ;bx=5 --> bh=00 bl=05
    pop ax  ;ax=2 --> 
    
    mul bl ; ax = 25
                      
    mov bh,0                  
    mov bl,10
    div bl  ;al=2, ah=5
    
    add al,30h ; makes 2 to 32h (hexi)
    add ah,30h ; makes 5 to 35h
    mov bl,ah  ;bl=35h 
    ;--- Display 2 seperate numbers 
    push ax
    mov ah,2
    mov dl,0ah
    int 21h
    mov dl,0dh
    int 21h    ;2
    pop ax 
    
    mov ah,2
	mov bh,0
	mov dh,5
	mov dl,25
	int 10h
	
    mov ah,2  ; first digit
    mov dl,al
    int 21h    ;2
    
              
    mov ah,2   ; second digit
    mov dl,bl
    int 21h     
    ;--- Continue
	mov ah,2
	mov bh,0
	mov dh,6
	mov dl,25
	int 10h
	
    mov ah,9
    mov dx,offset multiplicated
	int 21h
    jmp getInp
    
addition:   
     
    pop bx
    pop ax
     
    
    add AL,BL
    mov AH,0
    AAA
    
    
    mov BX,AX 
    add BH,48
    add BL,48 
    
	push BX
	
	mov ah,2
	mov bh,0
	mov dh,5
	mov dl,25
	int 10h
	
	pop BX
    mov AH,2
    mov DL,BH
    int 21H
     
    mov AH,2
    mov DL,BL
    int 21H
     
     ;--- Continue
	mov ah,2
	mov bh,0
	mov dh,6
	mov dl,25
	int 10h
	
    mov ah,9
    mov dx,offset added
	int 21h
    jmp getInp

 
subtraction:
   
    pop bx	; second number
	pop ax	; first number
	
	mov ch,0h	; resets checker if the number is negative
	
	cmp al,bl	; compares the numbers to know if the result is negative
	jb negative	; jump if al is lower bl
solve:
	sub al,bl	; subtraction of the two inputs
	add al,30h	; add 30h to turn the number to hexadecimal
	
	;---- display answer
	push ax
	
	mov ah,2	; next line
	mov dl,0ah
	int 21h
	mov dl,0dh
	int 21h
	
	mov ah,2
	mov bh,0
	mov dh,5
	mov dl,25
	int 10h
	
	cmp ch,1h	; checks if the number is negative
	je symbol
show:
	
	pop ax
	mov ah,2
	mov dl,al
	int 21h
	

	;--- Continue
	mov ah,2
	mov bh,0
	mov dh,6
	mov dl,25
	int 10h
	
	mov ah,9
   	mov dx,offset subbed
	int 21h
   	jmp getInp

negative:
	mov dl,al	;get value of bl
	mov al,bl	;put bl to al
	mov bl,dl	;put al to dl 
	mov ch,1h	; checker if the number is negative
	jmp solve
	
symbol:	
	mov dl,'-'	; print negative symbol
	int 21h
	jmp show   
   
           
 
    
division:
        
    pop bx	; second number
	mov bh,0h ; required before doing division
	cmp bx,0h
	je ifzero
	pop ax	; first number   
	mov ah,0h ; required before doing division
	
	div bl	; firstnum/secondnum
	
	add al,30h	;al = quotient (add 30h to turn the number to hexadecimal)
	add ah,30h	;ah = remainder (add 30h to turn the number to hexadecimal)
	mov bl,ah
	
	;---- Display answer
	mov ah,2
	mov bh,0
	mov dh,5
	mov dl,25
	int 10h
	
	mov ah,9	; display quotient
	mov dx,offset quotient
	int 21h
	mov ah,2	; (shows remainder)
	mov dl,al
	int 21h
	
	mov ah,2
	mov bh,0
	mov dh,6
	mov dl,25
	int 10h
	
	mov ah,9	; display quotient
	mov dx,offset remainder
	int 21h
	mov ah,2	; (show quotient)
	mov dl,bl
	int 21h

	;--- Continue
	mov ah,2
	mov bh,0
	mov dh,7
	mov dl,25
	int 10h

	mov ah,9
   	mov dx,offset divided
	int 21h
   	jmp getInp

ifzero:
	
	mov ah,2
	mov bh,0
	mov dh,6
	mov dl,25
	int 10h
	
	mov ah,9	; display quotient
	mov dx,offset undef
	int 21h
	jmp getInp
	
getInp:	;-- Get Yes or No From User

    mov ah,2
	mov bh,0
	mov dh,8
	mov dl,25
	int 10h
	
    mov ah,9
   	mov dx,offset continue
   	int 21h
	mov ah,1   ; get input for continying
	int 21h    ; al='y/n'

	cmp al,'y'  ; Check if Yes or No
	je screen
	cmp al,'Y'
	je screen
	cmp al,'n'
	je exit
	cmp al,'N'
	je exit
	jmp getInp      


screen:
    mov ah,6
    mov al,0
    mov bh,01111111b
    mov ch,0
    mov cl,0
    mov dh,24
    mov dl,80
    int 10h
	
	;mov ah,6 ;bg outside box ---blue boc
	mov al,0
	mov bh,00111110b
	mov ch,0
	mov cl,20 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,64 ; --- eto yung sa pahaba sa right
	int 10h
;mov ah,6 ;bg inside box -black box - screen
	mov al,0
	mov bh,00001110b
	mov ch,2 ;--- start  ng box sa taas
	mov cl,25 ;--- start ng box sa left
	mov dh,9 ;--- eto yung pahaba starting sa baba
	mov dl,58 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad 
	mov al,0
	mov bh,00001110b
	mov ch,11 ;--- start  ng box sa taas
	mov cl,25 ;--- start ng box sa left
	mov dh,13 ;--- eto yung pahaba starting sa baba
	mov dl,30 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad 
	mov al,0
	mov bh,00001110b
	mov ch,11 ;--- start  ng box sa taas
	mov cl,32 ;--- start ng box sa left
	mov dh,13 ;--- eto yung pahaba starting sa baba
	mov dl,37 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad 
	mov al,0
	mov bh,00001110b
	mov ch,11 ;--- start  ng box sa taas
	mov cl,39 ;--- start ng box sa left
	mov dh,13 ;--- eto yung pahaba starting sa baba
	mov dl,44 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad 
	mov al,0
	mov bh,00001110b
	mov ch,11 ;--- start  ng box sa taas
	mov cl,46 ;--- start ng box sa left
	mov dh,13 ;--- eto yung pahaba starting sa baba
	mov dl,51 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,11 ;--- start  ng box sa taas
	mov cl,53 ;--- start ng box sa left
	mov dh,13 ;--- eto yung pahaba starting sa baba
	mov dl,58 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,15 ;--- start  ng box sa taas
	mov cl,25 ;--- start ng box sa left
	mov dh,17 ;--- eto yung pahaba starting sa baba
	mov dl,30 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,15 ;--- start  ng box sa taas
	mov cl,32 ;--- start ng box sa left
	mov dh,17 ;--- eto yung pahaba starting sa baba
	mov dl,37 ; --- eto yung sa pahaba sa right
	int 10h
;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,15 ;--- start  ng box sa taas
	mov cl,39 ;--- start ng box sa left
	mov dh,17 ;--- eto yung pahaba starting sa baba
	mov dl,44 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,15 ;--- start  ng box sa taas
	mov cl,46 ;--- start ng box sa left
	mov dh,17 ;--- eto yung pahaba starting sa baba
	mov dl,51 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,15 ;--- start  ng box sa taas
	mov cl,53 ;--- start ng box sa left
	mov dh,17 ;--- eto yung pahaba starting sa baba
	mov dl,58 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,19 ;--- start  ng box sa taas
	mov cl,25 ;--- start ng box sa left
	mov dh,21 ;--- eto yung pahaba starting sa baba
	mov dl,30 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,19 ;--- start  ng box sa taas
	mov cl,32 ;--- start ng box sa left
	mov dh,21 ;--- eto yung pahaba starting sa baba
	mov dl,37 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,19 ;--- start  ng box sa taas
	mov cl,39 ;--- start ng box sa left
	mov dh,21 ;--- eto yung pahaba starting sa baba
	mov dl,44 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,19 ;--- start  ng box sa taas
	mov cl,46 ;--- start ng box sa left
	mov dh,21 ;--- eto yung pahaba starting sa baba
	mov dl,51 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg inside box --- number pad -- 
	mov al,0
	mov bh,00001110b
	mov ch,19 ;--- start  ng box sa taas
	mov cl,53 ;--- start ng box sa left
	mov dh,21 ;--- eto yung pahaba starting sa baba
	mov dl,58 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(1)
	mov al,0
	mov bh,00111110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,0 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,2 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(2)
	mov al,0
	mov bh,01101110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,3 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,5 ; --- eto yung sa pahaba sa right
	int 10h


;mov ah,6 ;bg outside box ---line(3)
	mov al,0
	mov bh,00101110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,6 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,8 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(4)
	mov al,0
	mov bh,00011110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,9 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,11 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(5)
	mov al,0
	mov bh,01001110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,12 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,14 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(6)
	mov al,0
	mov bh,01011110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,15 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,17 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(7)
	mov al,0
	mov bh,01101110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,18 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,20 ; --- eto yung sa pahaba sa right
	int 10h



;mov ah,6 ;bg outside box ---line(8)
	mov al,0
	mov bh,01011110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,63 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,65 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(8)
	mov al,0
	mov bh,01101110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,66 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,68 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(8)
	mov al,0
	mov bh,00101110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,69 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,71 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(8)
	mov al,0
	mov bh,00011110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,72 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,74 ; --- eto yung sa pahaba sa right
	int 10h

;mov ah,6 ;bg outside box ---line(8)
	mov al,0
	mov bh,01001110b
	mov ch,0  ;--- start  ng box sa taas
	mov cl,75 ;--- start ng box sa left
	mov dh,25 ;--- eto yung pahaba starting sa baba
	mov dl,77 ; --- eto yung sa pahaba sa right
	int 10h



;--- numbers (1)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,12
	mov dl,27
	int 10h

	mov ah,2    ;display char 
	mov dl,31h
	int 21h

;--- numbers (2)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,12
	mov dl,34
	int 10h

	mov ah,2    ;display char 
	mov dl,32h
	int 21h

;--- numbers (3)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,12
	mov dl,41
	int 10h

	mov ah,2    ;display char 
	mov dl,33h
	int 21h	
;--- numbers (4)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,16
	mov dl,27
	int 10h

	mov ah,2    ;display char 
	mov dl,34h
	int 21h	

;--- numbers (5)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,16
	mov dl,34
	int 10h

	mov ah,2    ;display char 
	mov dl,35h
	int 21h	


;--- numbers (6)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,16
	mov dl,41
	int 10h

	mov ah,2    ;display char 
	mov dl,36h
	int 21h	

;--- numbers (7)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,20
	mov dl,27
	int 10h

	mov ah,2    ;display char 
	mov dl,37h
	int 21h	

;--- numbers (8)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,20
	mov dl,34
	int 10h

	mov ah,2    ;display char 
	mov dl,38h
	int 21h	

;--- numbers (9)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,20
	mov dl,41
	int 10h

	mov ah,2    ;display char 
	mov dl,39h
	int 21h	

;--- numbers (0)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,20
	mov dl,48
	int 10h

	mov ah,2    ;display char 
	mov dl,30h
	int 21h	

;--- operators (+)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,12
	mov dl,48
	int 10h

	mov ah,2    ;display char 
	mov dl,2bh
	int 21h	

;--- operators (-)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,12
	mov dl,55
	int 10h

	mov ah,2    ;display char 
	mov dl,2dh
	int 21h	

;--- operators (*)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,16
	mov dl,48
	int 10h

	mov ah,2    ;display char 
	mov dl,2ah
	int 21h	

;--- operators (/)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,16
	mov dl,55
	int 10h

	mov ah,2    ;display char 
	mov dl,2fh
	int 21h	

;--- operators (=)
	mov ah,2   ; set cursor 
	mov bh,0
	mov dh,20
	mov dl,55
	int 10h

	mov ah,2    ;display char 
	mov dl,3dh
	int 21h	
	
	jmp loopOne

     
exit: 	
    mov ah,4ch
	int 21h
        
    
m   endp
end m