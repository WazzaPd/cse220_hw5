.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

.text
.globl zeroOut 
.globl place_tile 
.globl printBoard 
.globl placePieceOnBoard 
.globl test_fit 

# Function: zeroOut
# Arguments: None
# Returns: void
zeroOut:
    # Function prologue
    la $t0, board
    lw $t1, board_width		# width
    lw $t2, board_height	# height
    mul $t3, $t1, $t2 		# size
    li $t4, 0	 		#index
    
    iterate:
    	beq $t3, $t4, zero_done
    	
    	#get address
    	add $t5, $t4, $t0
    	
    	sb $zero, 0($t5)
    	
    	addi $t4, $t4, 1
    	j iterate

zero_done:
    # Function epilogue
    jr $ra

# Function: placePieceOnBoard
# Arguments: 
#   $a0 - address of piece struct
#   $a1 - ship_num
placePieceOnBoard:
    # Function prologue
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Load piece fields
    move $s1, $a1
    lw $s3, 0($a0)
    lw $s4, 4($a0)
    lw $s5, 8($a0)
    lw $s6, 12($a0)
    
    # First switch on type
    li $t0, 1
    beq $s3, $t0, piece_square
    li $t0, 2
    beq $s3, $t0, piece_line
    li $t0, 3
    beq $s3, $t0, piece_reverse_z
    li $t0, 4
    beq $s3, $t0, piece_L
    li $t0, 5
    beq $s3, $t0, piece_z
    li $t0, 6
    beq $s3, $t0, piece_reverse_L
    li $t0, 7
    beq $s3, $t0, piece_T
    j piece_done       # Invalid type

piece_done:
    
    # result of place piece is in s2
    li $t0, 1
    li $t1, 2
    li $t2, 3
    
    beq $s2, $zero, exitPlacePiece
    beq $s2, $t0, placePieceReturnOne
    beq $s2, $t1, placePieceReturnTwo
    beq $s2, $t2, placePieceReturnThree
    
    placePieceReturnOne:
    li $v0, 1
    jal zeroOut
    j exitPlacePiece
    
    placePieceReturnTwo:
    li $v0, 2
    jal zeroOut
    j exitPlacePiece
    
    placePieceReturnThree:
    li $v0, 3
    jal zeroOut
    
    exitPlacePiece:
    # Function epilogue
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    li $s1, 0
    li $s2, 0
    li $s3, 0
    li $s4, 0
    li $s5, 0
    li $s6, 0
    
    jr $ra
# Function: printBoard
# Arguments: None (uses global variables)
# Returns: void
# Uses global variables: board (char[]), board_width (int), board_height (int)

printBoard:
    # Function prologue
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    
    la $t0, board
    lw $t1, board_width		# width
    lw $t2, board_height	# height
    li $t3, 0 			# row index
    
    row_loop:
    	beq $t3, $t2, row_loop_done	#if row index == height
    	
    	li $t4, 0		# col index
    	
    	col_loop:
    		beq $t4, $t1, increment_row_loop		#if col index == width
    		
    		# Calculate offset
    		mul $t5, $t3, $t1
    		add $t5, $t5, $t4
    		
    		# get address
    		add $t6, $t5, $t0		#t6, now sotres the correct address
    		
    		lb $a0, 0($t6)
    		li $v0, 1		#print single char
    		syscall
    		
    		#print space
    		la $a0, space
    		li $v0, 4	
    		syscall
    		
    		addi $t4, $t4, 1
    		
    		j col_loop
    	
    	increment_row_loop:
    	addi $t3, $t3, 1
    	
    	#print newline
    	la $a0, newline
    	li $v0, 4	
    	syscall
    	
    	j row_loop
    
    row_loop_done:
    

    # Function epilogue
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra                # Return

# Function: place_tile
# Arguments: 
#   $a0 - row
#   $a1 - col
#   $a2 - value
# Returns:
#   $v0 - 0 if successful, 1 if occupied, 2 if out of bounds
# Uses global variables: board (char[]), board_width (int), board_height (int)

place_tile:
    la $t0, board
    lw $t1, board_width
    lw $t2, board_height
    
    bgt $a0, $t2, returnTwo	# row out of bounds
    bgt $a1, $t1, returnTwo	# col out of bounds
    
    #calculate offest address
    mul $t3, $a0, $t1		# row * width
    add $t3, $t3, $a1		# add col
    add $t3, $t3, $t0		# add to get offset address
    
    lb $t4, 0($t3)		# Get value of board
    
    bgt $t4, $zero, returnOne	# occupied check
    
    sb $a2, 0($t3)
    li $v0, 0
    
    j place_tile_exit
    
    returnOne:
    li $v0, 1
    j place_tile_exit
    
    returnTwo:
    li $v0, 2
    
    place_tile_exit: 
    jr $ra

# Function: test_fit
# Arguments: 
#   $a0 - address of piece array (5 pieces)
test_fit:
    # Function prologue
    jr $ra


T_orientation4:
    # Study the other T orientations in skeleton.asm to understand how to write this label/subroutine
    
    # row, col
    move $a0, $s5          # s5 contains row
    move $a1, $s6          # s6 contains col
    move $a2, $s1	   #s1 contains value
    jal place_tile
    or $s2, $s2, $v0
    
    #row +1, col
    move $a0, $s5
    move $a1, $s6          
    move $a2, $s1
    addi $a0, $a0, 1	   
    jal place_tile
    or $s2, $s2, $v0
    
    #row +1, col +1
    move $a0, $s5
    move $a1, $s6          
    move $a2, $s1
    addi $a0, $a0, 1
    addi $a1, $a1, 1	   
    jal place_tile
    or $s2, $s2, $v0
    
    #row +2, col
    move $a0, $s5
    move $a1, $s6          
    move $a2, $s1	
    addi $a0, $a0, 2   
    jal place_tile
    or $s2, $s2, $v0
    
    j piece_done

.include "skeleton.asm"
