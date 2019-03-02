# BASE CODE
# Fernando Mercado y Diego Mestre
# 28/02/19
.data
# IC	248 (3 discs)
# R	59
# I	158
# J	30
.text
#:::::::::::::::::::::  R E G I S T E R S  I N I T I A L I Z A T I O N  :::::::::::::::::::::::::::::::#
	addi $v0, $zero, 0			# 2POW(N)-1
	addi $v1, $zero, 0			# Free counter
	addi $a0, $zero, 3			# N
	addi $a1, $zero, 0			# EVEN/UNEVEN FLAG
	addi $a2, $zero, 0x20			# Tower Base Jumps 
	addi $a3, $zero, 0x40			# Tower Base Jumps
	addi $s0, $zero, 0			# d1 pointer
	addi $s1, $zero, 0			# d2 pointer
	addi $s2, $zero, 0x10010000		# dn pointer
	addi $s3, $zero, 0x10010000		# A pointer
	addi $s4, $a2, 0x1000fffc			# B pointer
	addi $s5, $a3, 0x1000fffc			# C pointer
	addi $s6, $zero, 0			# AUX pointer
	
#:::::::::::::::::::::  T O W E R S  I N I T I A L I Z A T I O N  :::::::::::::::::::::::::::::::#
	# MIN MOV CALC
	addi $t0, $zero, 1			# Places temporary 1
	sllv $v0, $t0, $a0			# Left shift N times a 1 = 2POW(n) operation
	sub $v0, $v0, 1				# Now $v0 holds the minumun movements necesary for completition.

	# IS N EVEN?				# $a1 sets if N is even[0] or uneven[1]
	andi $a1, $a0, 1			# A number && 1 and checks if it's even or uneven. Even numbers' LSB is 0, uneven is 1.
	
	# TOWER FILLING
	add $t0, $zero, $a0			# Load N into another decreasing register.
	add $t1, $zero, $s3			# Load first address into another increasing register.
FILL:	sw  $t0, 0($t1)				# Store disc.
	sub $t0, $t0, 1				# Next disc.
	add $t1, $t1, 4				# Next address in a tower.
	jal SONETWO
	beqz $t0, GOMAIN	
	j FILL
GOMAIN:	add $s3, $zero, $t1
	sub $s3, $s3, 4
	j MAIN

SONEP:	add $s0, $zero, $t1
	jr $ra
STWOP:	add $s1, $zero, $t1
	jr $ra
	
SONETWO:	beq $t0, 1, SONEP				# When 1 stores it's current address
	beq $t0, 2, STWOP				# When 2 stores it's current address
	jr $ra
#:::::::::::::::::::::  M A I N  C O D E  :::::::::::::::::::::::::::::::#
MAIN:  	beqz $v0, END
	andi $t8, $v0, 0x1			# For 1, $v0 is UNEVEN
         beq $t8, 1, FETCH1        			# Fetch 1
         andi $t8, $v0, 0x2			# For 2, 2nd bit of $v0 is always ON.
         beq $t8, 2, FETCH2                 		# Fetch 2
         
         lw $t0, 0($s2)				# Fetch d
   	andi $t9, $t0, 0x1			# Is EVEN/UNEVEN?
   	beq $t9, 1, MOVED1			# [Y]: Move UNEVEN.
   	j MOVED2					# [N]: Move EVEN
   	
FETCH1:	lw $t0, 0($s0)				# Fetch 1
	j MOVE1
	
FETCH2:	lw $t0, 0($s1)				# Fetch 2
	j MOVE2

MOVE1:	and $t8, $s0, $a2				# 
	beq $t8, $a2, BA				# If $s0 && 0x20 = 0x20, 1 is on B
	and $t8, $s0, $a3				# 
	beq $t8, $a3, CB				# If $s0 && 0x40 = 0x20, 1 is on C
	j AC

MOVE2:	and $t8, $s1, $a2				# 
	beq $t8, $a2, BC				# If $s0 && 0x20 = 0x20, 2 is on B
	and $t8, $s1, $a3				# 
	beq $t8, $a3, CA				# If $s0 && 0x40 = 0x20, 1 is on C
	j AB

MOVED1:	and $t8, $s2, $a2				# 
	beq $t8, $a2, BA				# If $s0 && 0x20 = 0x20, 2 is on B
	and $t8, $s2, $a3				# 
	beq $t8, $a3, CB				# If $s0 && 0x40 = 0x20, 1 is on C
	j AC

MOVED2:	and $t8, $s2, $a2				# 
	beq $t8, $a2, BC				# If $s0 && 0x20 = 0x20, 2 is on B
	and $t8, $s2, $a3				# 
	beq $t8, $a3, CA				# If $s0 && 0x40 = 0x20, 1 is on C
	j AB
	
AC:	sw $zero, 0($s3)				# Erases active slot's disc from active slot	
	sub $s3, $s3, 4				# Decreases A pointer
	add $s5, $s5, 4				# Increases C pointer
	sw $t0, 0($s5)				# Stores at C pointer slot.
	add $s6, $zero, $s5			# Aux pointer edit
	j AUXPTR
	
AB:	sw $zero, 0($s3)				# Erases active slot's disc from active slot
	sub $s3, $s3, 4				# Decreases A pointer
	add $s4, $s4, 4				# Increases B pointer
	sw $t0, 0($s4)				# Stores at B pointer slot.
	add $s6, $zero, $s4			# Aux pointer edit
	j AUXPTR
				
BA:	sw $zero, 0($s4)				# Erases active slot's disc from active slot
	sub $s4, $s4, 4				# Decreases B pointer
	add $s3, $s3, 4				# Increases A pointer
	sw $t0, 0($s3)				# Stores at A pointer slot.
	add $s6, $zero, $s3			# Aux pointer edit
	j AUXPTR
	
BC:	sw $zero, 0($s4)				# Erases active slot's disc from active slot
	sub $s4, $s4, 4				# Decreases B pointer
	add $s5, $s5, 4				# Increases C pointer
	sw $t0, 0($s5)				# Stores at C pointer slot.
	add $s6, $zero, $s5			# Aux pointer edit
	j AUXPTR
	
CA:	sw $zero, 0($s5)				# Erases active slot's disc from active slot
	sub $s5, $s5, 4				# Decreases C pointer
	add $s3, $s3, 4				# Increases A pointer
	sw $t0, 0($s3)				# Stores at A pointer slot.
	add $s6, $zero, $s3			# Aux pointer edit
	j AUXPTR
	
CB:	sw $zero, 0($s5)				# Erases active slot's disc from active slot	
	sub $s5, $s5, 4				# Decreases A pointer	
	add $s4, $s4, 4				# Increases A pointer
	sw $t0, 0($s4)				# Stores at A pointer slot.
	add $s6, $zero, $s4			# Aux pointer edit
	j AUXPTR
	
AUXPTR:	sub $v0, $v0, 1
	beq $t0, 1, AUX1
	beq $t0, 2, AUX2
	add $s2, $zero, $s6
	j MAIN
AUX1:	add $s0, $zero, $s6
	j MAIN
AUX2:	add $s1, $zero, $s6
	j MAIN
	
END:	nop
