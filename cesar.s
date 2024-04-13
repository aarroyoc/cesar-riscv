	# Cesar Cypher in RISCV-64 Assembly

.section	.data
msg_message:	.string "Message: "
msg_key:	.string "Key:     "
msg_cypher:	.string "Cypher:  "
msg_incorrect:  .string "Incorrect key\n"
original:	.space 100
key_buffer:	.space 100
cypher:	        .space 100
.section	.text
.global _start
_start:
	# Print Message
	li a7, 64 # Linux Write syscall is 64
	li a0, 1
	la a1, msg_message
	li a2, 9
	ecall

	# Read original message
	li a7, 63 # Linux Read syscall is 63
	li a0, 0
	la a1, original
	li a2, 99
	ecall

	# Print Key message
	li a7, 64
	li a0, 1
	la a1, msg_key
	la a2, 9
	ecall

	# Read (string) input of key
	li a7, 63
	li a0, 0
	la a1, key_buffer
	la a2, 99
	ecall

	la a0, key_buffer
	jal parse_key
	move a1, a0

	la a0, original
	la a2, cypher
	jal ra, cesar
	move s0, a0

	# Print cypher message
	li a7, 64
	li a0, 1
	la a1, msg_cypher
	li a2, 9
	ecall

	beqz s0, cypher_ok
	# Print incorrect message
	li a7, 64
	li a0, 1
	la a1, msg_incorrect
	li a2, 14
	ecall
	j exit

cypher_ok:
	# Print cyphered message
	li a7, 64
	li a0, 1
	la a1, cypher
	li a2, 99
	ecall

exit:	li a7, 93 # Linux Exit syscall is 93
	li a0, 0  # Return code
	ecall
	
# Parse string key to integer
# a0 - Location of key buffer
# a0 - Return of integer if no error 
parse_key:
	li t0, 0
	li t1, 10
	li t3, '\n'
	li t4, '-'
	lbu t2, 0(a0)
	beq t2, t4, parse_key_loop_negative
parse_key_loop:	
	lbu t2, 0(a0)
	beq t2, t3, exit_parse_key
	mul t0, t0, t1
	addi t2, t2, -48
	add t0, t0, t2
	addi a0, a0, 1
	j parse_key_loop
parse_key_loop_negative:
	lbu t2, 1(a0)
	beq t2, t3, exit_parse_key
	mul t0, t0, t1
	addi t2, t2, -48
	sub t0, t0, t2
	addi a0, a0, 1
	j parse_key_loop_negative
exit_parse_key:
	move a0, t0
	ret

# Cesar
# a0 - Location of original string
# a1 - Key
# a2 - Location of cypher string
cesar:
	addi sp, sp, -32
	sd s0, 24(sp)
	sd ra, 16(sp)
	sd s2, 8(sp)
	sd s3, 0(sp)
	move s0, a0
	move s2, a2
	li s3, '\n'
cesar_loop:
	lbu a0, 0(s0)
	beq a0, s3, exit_cesar_loop
	jal cesar_char
	sb a0, 0(s2)
	addi s0, s0, 1
	addi s2, s2, 1
	j cesar_loop
exit_cesar_loop:
	sb a0, 0(s2)
	sb zero, 1(s2)
	li a0, 0
	ld s0, 24(sp)
	ld ra, 16(sp)
	ld s2, 8(sp)
	ld s3, 0(sp)
	addi sp, sp, 32
	jalr zero, ra

# Cesar char
# Inputs:
# a0 - Character
# a1 - Key
# Outputs:
# a0 - Cypher char
cesar_char:
	add a0, a0, a1
	li t0, 32
	li t1, 126
	blt a0, t0, cesar_char_under_32
	bgt a0, t1, cesar_char_over_126
	ret
cesar_char_under_32:
	sub t0, t0, a0
	sub a0, t1, t0
	addi a0, a0, 1
	ret
cesar_char_over_126:
	sub t1, a0, t1
	add a0, t0, t1
	addi a0, a0, -1
	ret
