# Author: Anderson Walsh
# Implementation of selection sort
# Register usage for main:
#  only register usage is rsp for appropriate stack maintenance
#  eax and ebx to exit program
#sorted array stored in memory, myArray
.equ NUM_ELEMENTS, 10
.data
    myArray: .quad 5,-1, 4, 55, -30, 2, 1, 9, -55, 10
.text
.global main
main:
	pushq $myArray   #push parameters on stack
	pushq $NUM_ELEMENTS
	callq mySort 
	addq $16, %rsp #reset stack pointer
	jmp done

done:
    movl $1, %eax   #return 0
    movl $0, %ebx
    int $0x80
    retq

#mySort utilizes selection sort to order array of ints 
#Parameters on the stack
#   NUM_ELEMENTS, myArray
#modifies array directly by accessing address in memory
#Register usage:
#   rax stores &myArray[0]
#   rbx: minimum value's index, found each iteration of outer loop
#   rcx: loop counter, "i", for outer loop
#   rdx: loop counter, "j", for inner loop 
#   r8: store current minimum for comparison to each subsequent element of array
#   r9: store NUM_ELEMENTS for cmp operation

.type mySort, @function
mySort:  
    pushq %rbp  #establish stack frame for mySort
    movq %rsp, %rbp
    pushfq
    pushq %rax
    pushq %rbx  
    pushq %rcx
    pushq %rdx 
    pushq %r8   
    pushq %r9
    
    movq 24(%rbp), %rax #retrieve parameters from the stack, place in registers
    movq 16(%rbp), %r9
    movq $0, %rcx       #begin iterating from index zero
    
    outerLoop:
        cmp %r9, %rcx          #sort is done if i has surpassed array size
        jge sortDone
        movq %rcx, %rbx        #start by assuming next smallest value is at myArray[i] of outer loop
        movq %rcx, %rdx        #indices below arr[rcx] are sorted, inner loop starts at rcx + 1
        addq $1, %rdx      
        innerLoop:
            cmp %r9, %rdx
            jge innerLoopDone           #inner loop done if j has surpassed array size
            movq (%rax, %rbx, 8), %r8   #store current min in r8 for comparison
            cmp (%rax, %rdx, 8), %r8    #check arr[j] against arr[min]
            jle ifDone                  #jump if arr[min] < arr[j], else new arr[min] found
            movq %rdx, %rbx
            ifDone:
                inc %rdx                #check next val
                jmp innerLoop
            
        innerLoopDone:
            leaq (%rax, %rcx, 8), %rdx  #new smallest item found, swap with outer loop index
            pushq %rdx
            leaq (%rax, %rbx, 8), %rdx
            pushq %rdx
            callq mySwap
            addq $16, %rsp  #reset stack pointer, i+=1, proceed to next iteration of outer loop
            inc %rcx
            jmp outerLoop
    sortDone:
        popq %r9
        popq %r8
        popq %rdx
        popq %rcx
        popq %rbx       #restore general purpose registers, flags register, and calling stack frame
        popq %rax
        popfq
        popq %rbp
        retq
    
# mySwap swaps two values pointed to by the parameters  
# Parameters on the stack 
#   pointer to first value
#   pointer to second value
# Returns nothing
# Register usage
#   rax first parameter
#   rbx second parameter
#   rcx number pointed to by first parameter
#   rdx number pointed to by second parameter
.type mySwap, @function
mySwap:  
    pushq %rbp        # establish stack frame
    movq %rsp, %rbp    # rbp = rsp
    pushq %rax          # save rax, rbx, rcx, rdx
    pushq %rbx
    pushq %rcx
    pushq %rdx
    movq 24(%rbp), %rax #rax-> 1st parameter
    movq 16(%rbp), %rbx # rbx -> 2nd parameter
    #movq (%rax, %r9, 8), %rcx   # rcx = number 1st parm points to
    #movq (%rax, %rbx, 8), %rdx   # rdx = number 2nd parm points to
    #movq %rcx, (%rax, %rbx, 8)   # 2nd num = 1st
    #movq %rdx, (%rax, %r9, 8)   # 1st num = 2nd
    movq (%rax), %rcx   # rcx = number 1st parm points to
    movq (%rbx), %rdx   # rdx = number 2nd parm points to
    movq %rcx, (%rbx)   # 2nd num = 1st
    movq %rdx, (%rax)  # 1st num = 2nd
    popq %rdx       # restore registers
    popq %rcx
    popq %rbx
    popq %rax
    pop %rbp        # restore calling stack frame
    retq