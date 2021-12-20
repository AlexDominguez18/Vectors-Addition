;Definicion de constantes
section .data

LF      equ 10
TAB     equ 9
NULL    equ 0
TRUE    equ 1
FALSE   equ 0
VECTOR_SIZE equ 8

;Metodos de consola
STDIN           equ 0
STDOUT          equ 1
STDERR          equ 2
EXIT_SUCCESS    equ 0

;Modos de archivo
SYS_read    equ 0
SYS_write   equ 1
SYS_open    equ 2
SYS_close   equ 3
SYS_fork    equ 57
SYS_exit    equ 60
SYS_creat   equ 85
SYS_time    equ 201

;Bandera para archivos
O_CREAT     equ 0x40
O_TRUNC     equ 0x200
O_APPEND    equ 0x400
O_RDONLY    equ 000000q
O_WRONLY    equ 000001q
O_RDWR      equ 000002q
S_IRUSR     equ 00400q
S_IWUSR     equ 00200q
S_IXUSR     equ 00100q

;Unidades numericas
millar      dw 1000
centena     dw 100
decena      dw 10
uniNum      dw 1000,100,10,1
bufferLec   db 0,0,0
residuo     db 0

nombreArchivo   db "listasNumericas.txt", NULL
archivoSalida   db "salida.txt", NULL
msjVector1      db "Vector 1:", LF, NULL
longMsjV1       equ $-msjVector1
msjVector2      db "Vector 2:", LF, NULL
longMsjV2       equ $-msjVector2
msjVectorSuma   db "Vector suma:", LF, NULL
longMsjVs       equ $-msjVectorSuma
msjMultResult   db "Producto punto = ", NULL
longMultResult  equ $-msjMultResult
msjErrorAbrir   db "Error al abrir el archivo", LF, NULL
msjErrorLeer    db "Error al leer del archivo", LF, NULL
msjErrorEsc     db "Error al escribir al archivo", LF, NULL

descArchivo     dq 0
descSalida      dq 0
charActual      db 0
numeroTemp      db 0
separador       db 0x2C
endl            db 10

;Reserva de memoria
section .bss

vector1     resb 8
vector2     resb 8
resultSuma  resb 8
resultMult  resd 1

;Codigo
section .text
global main
main:
    ;EL protocolo
    push rbp
    mov rbp, rsp
    ;Limpiando registros
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx

abrirArchivo:
    ;Apertura en modo lectura del archivo listasNumericas.txt
    mov rax, SYS_open
    mov rdi, nombreArchivo
    mov rsi, O_RDONLY
    syscall
    ;Validacion de apertura de archivo
    cmp rax, 0
    jl errorAlAbrir
    ;Recuperacion del descriptor del archivo listasNumericas.txt
    mov qword[descArchivo], rax

crearArchivo:
    ;Creacion del archivo salida.txt
    mov rax, SYS_creat
    mov rdi, archivoSalida
    mov rsi, S_IRUSR | S_IWUSR
    syscall
    ;Validacion de la creacion del archivo de salida.txt
    cmp rax, 0
    jl errorAlAbrir
    ;Recuperacion del descriptor del archivo salida.txt
    mov qword[descSalida], rax
    
leerVector1:
    lea rsi, [rel bufferLec]
    lea rdi, [rel vector1]
    leerCharVector1:
    push rsi
    push rdi
    ;Leemos un caracter
    mov rax, SYS_read
    mov rdi, qword[descArchivo]
    mov rsi, charActual
    mov rdx, 1
    syscall

    pop rdi
    pop rsi

    ;Validamos la lectura del archivo
    cmp rax, 0
    jl errorAlLeer
    ;Validamos que el char leido no sea ','
    cmp byte[charActual], 0x2C
    je guardarVector1
    ;Validamos que el char leido no sea LF
    cmp byte[charActual], LF
    je guardarVector1
    ;Guardamos el numero en el buffer
    mov al, byte[charActual]
    mov byte[rel rsi], al
    inc rsi
    jmp leerCharVector1

guardarVector1:
    dec rsi
    mov al, byte[rel rsi]
    sub al, 0x30
    add byte[rel numeroTemp], al
    dec rsi
    mov al, byte[rel rsi]
    sub al, 0x30
    mov bl, byte[decena]
    mul bl
    add byte[rel numeroTemp], al
    mov al, byte[rel numeroTemp]
    mov byte[rel rdi], al
    inc rdi
    ;Validamos que el char leido no sea LF
    cmp byte[charActual], LF
    je leerVector2
    ;Reseteo de indice
    mov byte[rel numeroTemp], NULL
    lea rsi, [rel bufferLec]
    jmp leerCharVector1
    
leerVector2:
    lea rsi, [rel bufferLec]
    lea rdi, [rel vector2]
    mov byte[numeroTemp], 0
    
    leerCharVector2:
    push rsi
    push rdi
    ;Leemos un caracter
    mov rax, SYS_read
    mov rdi, qword[descArchivo]
    mov rsi, charActual
    mov rdx, 1
    syscall

    pop rdi
    pop rsi

    ;Validamos la lectura del archivo
    cmp rax, 0
    jl errorAlLeer
    ;Validamos que el char leido no sea ','
    cmp byte[charActual], 0x2C
    je guardarVector2
    ;Validamos que el char leido no sea LF
    cmp byte[charActual], LF
    je guardarVector2
    ;Guardamos el numero en el buffer
    mov al, byte[charActual]
    mov byte[rel rsi], al
    inc rsi
    jmp leerCharVector2

guardarVector2:
    dec rsi
    mov al, byte[rel rsi]
    sub al, 0x30
    add byte[rel numeroTemp], al
    dec rsi
    mov al, byte[rel rsi]
    sub al, 0x30
    mov bl, byte[decena]
    mul bl
    add byte[rel numeroTemp], al
    mov al, byte[rel numeroTemp]
    mov byte[rel rdi], al
    inc rdi
    ;Validamos que el char leido no sea LF
    cmp byte[charActual], LF
    je realizarOperaciones
    ;Reseteo de indice
    mov byte[rel numeroTemp], NULL
    lea rsi, [rel bufferLec]
    jmp leerCharVector2

realizarOperaciones:
    ;Suma de los vectores
    xor rax, rax
    mov rcx, VECTOR_SIZE
    ;Direcciones de memoria de los vectores
    lea rbx, [rel resultSuma]
    lea rsi, [rel vector1]
    lea rdi, [rel vector2]
sumarSiguiente:
    mov al, byte[rsi]
    add al, byte[rdi]
    mov [rbx], al
    inc rsi
    inc rdi
    inc rbx
    loopnz sumarSiguiente
    ;Producto punto de los vectores
    xor rax, rax
    mov rcx, VECTOR_SIZE
    lea rbx, [rel resultSuma]
    lea rsi, [rel vector1]
    lea rdi, [rel vector2]
multSiguiente:
    mov al, byte[rsi]
    mov bl, byte[rdi]
    mul bl
    add [resultMult], rax
    inc rsi
    inc rdi
    inc rbx
    loopnz multSiguiente

imprimirResultados:
    xor rax, rax
    xor rbx, rbx
    xor rdx, rdx
    imprimirVector1:
    ;Imprimir mensaje del vector 1
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, msjVector1
    mov rdx, longMsjV1
    syscall
    ;Escribir mensaje del vector 1
    mov rax, SYS_write
    mov rdi, qword[descSalida]
    mov rsi, msjVector1
    mov rdx, longMsjV1
    syscall
    ;Preparamos el indice y el registro contador
    mov rcx, VECTOR_SIZE
    lea rsi,[rel vector1+7]
    call dividirNumero

    imprimirVector2:
    ;Imprimir mensaje del vector 2
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, msjVector2
    mov rdx, longMsjV2
    syscall
    ;Escribir mensaje del vector 2
    mov rax, SYS_write
    mov rdi, qword[descSalida]
    mov rsi, msjVector2
    mov rdx, longMsjV2
    syscall
    ;Preparamos el indice y el registro contador
    mov rcx, VECTOR_SIZE
    lea rsi, [rel vector2+7]
    call dividirNumero

    imprimirVectorSuma:
    ;Imprimir mensaje vector suma
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, msjVectorSuma
    mov rdx, longMsjVs
    syscall
    ;Escribir mensaje vector suma
    mov rax, SYS_write
    mov rdi, qword[descSalida]
    mov rsi, msjVectorSuma
    mov rdx, longMsjVs
    syscall
    ;Preparamos el indice y el registro contador
    mov rcx, VECTOR_SIZE
    lea rsi, [rel resultSuma+7]
    call dividirNumero
    jmp imprimirProductoPunto
    
dividirNumero:
    mov al, [rel rsi]          ;Guardamos el valor de vector[n-1]
    mov byte[numeroTemp], al
    mov bl, byte[decena]        
    div bl                     ;Guardamos el residuo en ah y el resultado en al
    mov byte[residuo], ah
    push rsi                   ;Guardamos el valor actual de rsi en la pila
    push rcx
    ;Checamos si el residuo es 0
    cmp al, NULL
    je imprimirResiduo
    ;Imprimir resultado en consola
    mov byte[charActual], al
    add byte[charActual], 0x30
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, charActual
    mov rdx, 1
    syscall
    ;Escribir resulado en archivo
    mov rax, SYS_write
    mov rdi, qword[descSalida]
    mov rsi, charActual
    mov rdx, 1
    syscall
    ;Limpiamos registros
    xor rax, rax
    xor rbx, rbx
    xor rdx, rdx
    ;Division del residuo entre la decena
    mov al, byte[residuo]
    mov bl, byte[decena]
    div bl
    imprimirResiduo:
    mov byte[charActual], ah
    add byte[charActual], 0x30
    ;Imprimir residuo en consola
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, charActual
    mov rdx, 1
    syscall
    ;Escribir residuo en archivo listasNumericas
    mov rax, SYS_write
    mov rdi, qword[descSalida]
    mov rsi, charActual
    mov rdx, 1
    syscall
    ;Imprimir coma en consola
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, separador 
    mov rdx, 1
    syscall
    ;Escribir coma en archivo
    mov rax, SYS_write
    mov rdi, qword[descSalida]
    mov rsi, separador
    mov rdx, 1
    syscall
    
    pop rcx
    pop rsi     ;Recuperamos el valor del indice del vector 1
    dec rsi     ;Cambiamos el valor del indice
    dec rcx     ;Decrementamos el contador
    ;Checamos si el contador es 0
    cmp rcx, 0
    jne dividirNumero
    ;Imprimir salto de linea
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, endl
    mov rdx, 1
    syscall
    ;Escribir salto de linea
    mov rax, SYS_write
    mov rdi, qword[descSalida]
    mov rsi, endl
    mov rdx, 1
    syscall
    ;Regresamos al flujo del programa
    ret
    
imprimirProductoPunto:
    ;Limpiamos registros
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx
    ;Imprimir mensaje de producto punto
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, msjMultResult
    mov rdx, longMultResult
    syscall
    ;Escribir mensaje de producto punto
    mov rax, SYS_write
    mov rdi, qword[descSalida]
    mov rsi, msjMultResult
    mov rdx, longMultResult
    syscall
    ;Mostrar el numero
    mov rcx, 4
    lea rsi, [rel uniNum]
    divisionDecimal:
    xor rax, rax
    xor rdx, rdx
    xor rbx, rbx
    mov ax, word[resultMult]
    mov bx, word[rsi]
    div bx                      ;Resultado se almacena en ax y el residuo en dx
    mov byte[charActual], al
    add byte[charActual], 0x30
    mov word[resultMult], dx
    push rsi
    push rcx                    ;Conservar el contador
    ;Imprimir en consola
    mov rax, SYS_write
    mov rdi, STDOUT
    mov rsi, charActual
    mov rdx, 1
    syscall
    ;Escribir en el archivo salida
    mov rax, SYS_write
    mov rdi, qword[descSalida]
    mov rsi, charActual
    mov rdx, 1
    syscall

    pop rcx                 ;Recuperar el valor del contador
    pop rsi
    add rsi, 2
    loopnz divisionDecimal

cerrarArchivos:
    ;Cerramos el archivo de salida
    mov rax, SYS_close
    mov rdi, qword[descSalida]
    syscall
    ;Cerramos el archivo de listasNumericas
    mov rax, SYS_close
    mov rdi, qword[descArchivo]
    syscall

fin:
    ;Final del protocolo
    pop rbp
    mov rsp, rbp
    mov rax, 60
    mov rdi, 0
    syscall


;Error al abrir:
errorAlAbrir:
	mov	rdi, msjErrorAbrir
	call	imprimirString
	
	jmp	pruebaTerminada

; Error al leer:
errorAlLeer:
	mov	rdi, msjErrorLeer
	call	imprimirString

	jmp	pruebaTerminada

; Error al escribir:
errorAlEscribir:
	mov	rdi, msjErrorEsc
	call	imprimirString

	jmp	pruebaTerminada

pruebaTerminada:
	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall

global imprimirString
imprimirString:
	push	rbp
	mov	rbp, rsp
	push	rbx

; Contamos los caracteres

	mov	rbx, rdi
	mov	rdx, 0
    conteoCharsLoop:
	cmp	byte [rbx], NULL
	je	conteoCharsTerminado
	inc	rdx
	inc	rbx
	jmp	conteoCharsLoop
    conteoCharsTerminado:
	cmp	rdx, 0
	je	parteTerminada

; Imprimimos la cadena

	mov	rax, SYS_write
	mov	rsi, rdi
	mov	rdi, STDOUT

	syscall

   parteTerminada:
	pop	rbx
	pop	rbp
	ret

