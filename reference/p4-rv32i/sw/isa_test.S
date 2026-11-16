  .section .text.init
  .globl _start
_start:
  # case 1
  li x28, 1
  li x1, 0x0
  li x2, 0x0
  add x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 2
  li x28, 2
  li x1, 0x0
  li x2, 0x1
  add x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 3
  li x28, 3
  li x1, 0x0
  li x2, 0x1f
  add x3, x1, x2
  li x29, 0x1f
  bne x3, x29, fail
  # case 4
  li x28, 4
  li x1, 0x0
  li x2, 0x80000000
  add x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 5
  li x28, 5
  li x1, 0x0
  li x2, 0xffffffff
  add x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 6
  li x28, 6
  li x1, 0x0
  li x2, 0x7
  add x3, x1, x2
  li x29, 0x7
  bne x3, x29, fail
  # case 7
  li x28, 7
  li x1, 0x1
  li x2, 0x0
  add x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 8
  li x28, 8
  li x1, 0x1
  li x2, 0x1
  add x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 9
  li x28, 9
  li x1, 0x1
  li x2, 0x1f
  add x3, x1, x2
  li x29, 0x20
  bne x3, x29, fail
  # case 10
  li x28, 10
  li x1, 0x1
  li x2, 0x80000000
  add x3, x1, x2
  li x29, 0x80000001
  bne x3, x29, fail
  # case 11
  li x28, 11
  li x1, 0x1
  li x2, 0xffffffff
  add x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 12
  li x28, 12
  li x1, 0x1
  li x2, 0x7
  add x3, x1, x2
  li x29, 0x8
  bne x3, x29, fail
  # case 13
  li x28, 13
  li x1, 0x2
  li x2, 0x0
  add x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 14
  li x28, 14
  li x1, 0x2
  li x2, 0x1
  add x3, x1, x2
  li x29, 0x3
  bne x3, x29, fail
  # case 15
  li x28, 15
  li x1, 0x2
  li x2, 0x1f
  add x3, x1, x2
  li x29, 0x21
  bne x3, x29, fail
  # case 16
  li x28, 16
  li x1, 0x2
  li x2, 0x80000000
  add x3, x1, x2
  li x29, 0x80000002
  bne x3, x29, fail
  # case 17
  li x28, 17
  li x1, 0x2
  li x2, 0xffffffff
  add x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 18
  li x28, 18
  li x1, 0x2
  li x2, 0x7
  add x3, x1, x2
  li x29, 0x9
  bne x3, x29, fail
  # case 19
  li x28, 19
  li x1, 0x7fffffff
  li x2, 0x0
  add x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 20
  li x28, 20
  li x1, 0x7fffffff
  li x2, 0x1
  add x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 21
  li x28, 21
  li x1, 0x7fffffff
  li x2, 0x1f
  add x3, x1, x2
  li x29, 0x8000001e
  bne x3, x29, fail
  # case 22
  li x28, 22
  li x1, 0x7fffffff
  li x2, 0x80000000
  add x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 23
  li x28, 23
  li x1, 0x7fffffff
  li x2, 0xffffffff
  add x3, x1, x2
  li x29, 0x7ffffffe
  bne x3, x29, fail
  # case 24
  li x28, 24
  li x1, 0x7fffffff
  li x2, 0x7
  add x3, x1, x2
  li x29, 0x80000006
  bne x3, x29, fail
  # case 25
  li x28, 25
  li x1, 0x80000000
  li x2, 0x0
  add x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 26
  li x28, 26
  li x1, 0x80000000
  li x2, 0x1
  add x3, x1, x2
  li x29, 0x80000001
  bne x3, x29, fail
  # case 27
  li x28, 27
  li x1, 0x80000000
  li x2, 0x1f
  add x3, x1, x2
  li x29, 0x8000001f
  bne x3, x29, fail
  # case 28
  li x28, 28
  li x1, 0x80000000
  li x2, 0x80000000
  add x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 29
  li x28, 29
  li x1, 0x80000000
  li x2, 0xffffffff
  add x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 30
  li x28, 30
  li x1, 0x80000000
  li x2, 0x7
  add x3, x1, x2
  li x29, 0x80000007
  bne x3, x29, fail
  # case 31
  li x28, 31
  li x1, 0xffffffff
  li x2, 0x0
  add x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 32
  li x28, 32
  li x1, 0xffffffff
  li x2, 0x1
  add x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 33
  li x28, 33
  li x1, 0xffffffff
  li x2, 0x1f
  add x3, x1, x2
  li x29, 0x1e
  bne x3, x29, fail
  # case 34
  li x28, 34
  li x1, 0xffffffff
  li x2, 0x80000000
  add x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 35
  li x28, 35
  li x1, 0xffffffff
  li x2, 0xffffffff
  add x3, x1, x2
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 36
  li x28, 36
  li x1, 0xffffffff
  li x2, 0x7
  add x3, x1, x2
  li x29, 0x6
  bne x3, x29, fail
  # case 37
  li x28, 37
  li x1, 0x12345678
  li x2, 0x0
  add x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 38
  li x28, 38
  li x1, 0x12345678
  li x2, 0x1
  add x3, x1, x2
  li x29, 0x12345679
  bne x3, x29, fail
  # case 39
  li x28, 39
  li x1, 0x12345678
  li x2, 0x1f
  add x3, x1, x2
  li x29, 0x12345697
  bne x3, x29, fail
  # case 40
  li x28, 40
  li x1, 0x12345678
  li x2, 0x80000000
  add x3, x1, x2
  li x29, 0x92345678
  bne x3, x29, fail
  # case 41
  li x28, 41
  li x1, 0x12345678
  li x2, 0xffffffff
  add x3, x1, x2
  li x29, 0x12345677
  bne x3, x29, fail
  # case 42
  li x28, 42
  li x1, 0x12345678
  li x2, 0x7
  add x3, x1, x2
  li x29, 0x1234567f
  bne x3, x29, fail
  # case 43
  li x28, 43
  li x1, 0xfedcba98
  li x2, 0x0
  add x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 44
  li x28, 44
  li x1, 0xfedcba98
  li x2, 0x1
  add x3, x1, x2
  li x29, 0xfedcba99
  bne x3, x29, fail
  # case 45
  li x28, 45
  li x1, 0xfedcba98
  li x2, 0x1f
  add x3, x1, x2
  li x29, 0xfedcbab7
  bne x3, x29, fail
  # case 46
  li x28, 46
  li x1, 0xfedcba98
  li x2, 0x80000000
  add x3, x1, x2
  li x29, 0x7edcba98
  bne x3, x29, fail
  # case 47
  li x28, 47
  li x1, 0xfedcba98
  li x2, 0xffffffff
  add x3, x1, x2
  li x29, 0xfedcba97
  bne x3, x29, fail
  # case 48
  li x28, 48
  li x1, 0xfedcba98
  li x2, 0x7
  add x3, x1, x2
  li x29, 0xfedcba9f
  bne x3, x29, fail
  # case 49
  li x28, 49
  li x5, 0x55
  add x5, x5, x5
  li x29, 0xaa
  bne x5, x29, fail
  # case 50
  li x28, 50
  li x1, 9
  li x2, 3
  add x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 51
  li x28, 51
  li x1, 0x0
  li x2, 0x0
  sub x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 52
  li x28, 52
  li x1, 0x0
  li x2, 0x1
  sub x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 53
  li x28, 53
  li x1, 0x0
  li x2, 0x1f
  sub x3, x1, x2
  li x29, 0xffffffe1
  bne x3, x29, fail
  # case 54
  li x28, 54
  li x1, 0x0
  li x2, 0x80000000
  sub x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 55
  li x28, 55
  li x1, 0x0
  li x2, 0xffffffff
  sub x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 56
  li x28, 56
  li x1, 0x0
  li x2, 0x7
  sub x3, x1, x2
  li x29, 0xfffffff9
  bne x3, x29, fail
  # case 57
  li x28, 57
  li x1, 0x1
  li x2, 0x0
  sub x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 58
  li x28, 58
  li x1, 0x1
  li x2, 0x1
  sub x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 59
  li x28, 59
  li x1, 0x1
  li x2, 0x1f
  sub x3, x1, x2
  li x29, 0xffffffe2
  bne x3, x29, fail
  # case 60
  li x28, 60
  li x1, 0x1
  li x2, 0x80000000
  sub x3, x1, x2
  li x29, 0x80000001
  bne x3, x29, fail
  # case 61
  li x28, 61
  li x1, 0x1
  li x2, 0xffffffff
  sub x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 62
  li x28, 62
  li x1, 0x1
  li x2, 0x7
  sub x3, x1, x2
  li x29, 0xfffffffa
  bne x3, x29, fail
  # case 63
  li x28, 63
  li x1, 0x2
  li x2, 0x0
  sub x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 64
  li x28, 64
  li x1, 0x2
  li x2, 0x1
  sub x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 65
  li x28, 65
  li x1, 0x2
  li x2, 0x1f
  sub x3, x1, x2
  li x29, 0xffffffe3
  bne x3, x29, fail
  # case 66
  li x28, 66
  li x1, 0x2
  li x2, 0x80000000
  sub x3, x1, x2
  li x29, 0x80000002
  bne x3, x29, fail
  # case 67
  li x28, 67
  li x1, 0x2
  li x2, 0xffffffff
  sub x3, x1, x2
  li x29, 0x3
  bne x3, x29, fail
  # case 68
  li x28, 68
  li x1, 0x2
  li x2, 0x7
  sub x3, x1, x2
  li x29, 0xfffffffb
  bne x3, x29, fail
  # case 69
  li x28, 69
  li x1, 0x7fffffff
  li x2, 0x0
  sub x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 70
  li x28, 70
  li x1, 0x7fffffff
  li x2, 0x1
  sub x3, x1, x2
  li x29, 0x7ffffffe
  bne x3, x29, fail
  # case 71
  li x28, 71
  li x1, 0x7fffffff
  li x2, 0x1f
  sub x3, x1, x2
  li x29, 0x7fffffe0
  bne x3, x29, fail
  # case 72
  li x28, 72
  li x1, 0x7fffffff
  li x2, 0x80000000
  sub x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 73
  li x28, 73
  li x1, 0x7fffffff
  li x2, 0xffffffff
  sub x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 74
  li x28, 74
  li x1, 0x7fffffff
  li x2, 0x7
  sub x3, x1, x2
  li x29, 0x7ffffff8
  bne x3, x29, fail
  # case 75
  li x28, 75
  li x1, 0x80000000
  li x2, 0x0
  sub x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 76
  li x28, 76
  li x1, 0x80000000
  li x2, 0x1
  sub x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 77
  li x28, 77
  li x1, 0x80000000
  li x2, 0x1f
  sub x3, x1, x2
  li x29, 0x7fffffe1
  bne x3, x29, fail
  # case 78
  li x28, 78
  li x1, 0x80000000
  li x2, 0x80000000
  sub x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 79
  li x28, 79
  li x1, 0x80000000
  li x2, 0xffffffff
  sub x3, x1, x2
  li x29, 0x80000001
  bne x3, x29, fail
  # case 80
  li x28, 80
  li x1, 0x80000000
  li x2, 0x7
  sub x3, x1, x2
  li x29, 0x7ffffff9
  bne x3, x29, fail
  # case 81
  li x28, 81
  li x1, 0xffffffff
  li x2, 0x0
  sub x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 82
  li x28, 82
  li x1, 0xffffffff
  li x2, 0x1
  sub x3, x1, x2
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 83
  li x28, 83
  li x1, 0xffffffff
  li x2, 0x1f
  sub x3, x1, x2
  li x29, 0xffffffe0
  bne x3, x29, fail
  # case 84
  li x28, 84
  li x1, 0xffffffff
  li x2, 0x80000000
  sub x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 85
  li x28, 85
  li x1, 0xffffffff
  li x2, 0xffffffff
  sub x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 86
  li x28, 86
  li x1, 0xffffffff
  li x2, 0x7
  sub x3, x1, x2
  li x29, 0xfffffff8
  bne x3, x29, fail
  # case 87
  li x28, 87
  li x1, 0x12345678
  li x2, 0x0
  sub x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 88
  li x28, 88
  li x1, 0x12345678
  li x2, 0x1
  sub x3, x1, x2
  li x29, 0x12345677
  bne x3, x29, fail
  # case 89
  li x28, 89
  li x1, 0x12345678
  li x2, 0x1f
  sub x3, x1, x2
  li x29, 0x12345659
  bne x3, x29, fail
  # case 90
  li x28, 90
  li x1, 0x12345678
  li x2, 0x80000000
  sub x3, x1, x2
  li x29, 0x92345678
  bne x3, x29, fail
  # case 91
  li x28, 91
  li x1, 0x12345678
  li x2, 0xffffffff
  sub x3, x1, x2
  li x29, 0x12345679
  bne x3, x29, fail
  # case 92
  li x28, 92
  li x1, 0x12345678
  li x2, 0x7
  sub x3, x1, x2
  li x29, 0x12345671
  bne x3, x29, fail
  # case 93
  li x28, 93
  li x1, 0xfedcba98
  li x2, 0x0
  sub x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 94
  li x28, 94
  li x1, 0xfedcba98
  li x2, 0x1
  sub x3, x1, x2
  li x29, 0xfedcba97
  bne x3, x29, fail
  # case 95
  li x28, 95
  li x1, 0xfedcba98
  li x2, 0x1f
  sub x3, x1, x2
  li x29, 0xfedcba79
  bne x3, x29, fail
  # case 96
  li x28, 96
  li x1, 0xfedcba98
  li x2, 0x80000000
  sub x3, x1, x2
  li x29, 0x7edcba98
  bne x3, x29, fail
  # case 97
  li x28, 97
  li x1, 0xfedcba98
  li x2, 0xffffffff
  sub x3, x1, x2
  li x29, 0xfedcba99
  bne x3, x29, fail
  # case 98
  li x28, 98
  li x1, 0xfedcba98
  li x2, 0x7
  sub x3, x1, x2
  li x29, 0xfedcba91
  bne x3, x29, fail
  # case 99
  li x28, 99
  li x5, 0x55
  sub x5, x5, x5
  li x29, 0x0
  bne x5, x29, fail
  # case 100
  li x28, 100
  li x1, 9
  li x2, 3
  sub x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 101
  li x28, 101
  li x1, 0x0
  li x2, 0x0
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 102
  li x28, 102
  li x1, 0x0
  li x2, 0x1
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 103
  li x28, 103
  li x1, 0x0
  li x2, 0x1f
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 104
  li x28, 104
  li x1, 0x0
  li x2, 0x80000000
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 105
  li x28, 105
  li x1, 0x0
  li x2, 0xffffffff
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 106
  li x28, 106
  li x1, 0x0
  li x2, 0x7
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 107
  li x28, 107
  li x1, 0x1
  li x2, 0x0
  sll x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 108
  li x28, 108
  li x1, 0x1
  li x2, 0x1
  sll x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 109
  li x28, 109
  li x1, 0x1
  li x2, 0x1f
  sll x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 110
  li x28, 110
  li x1, 0x1
  li x2, 0x80000000
  sll x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 111
  li x28, 111
  li x1, 0x1
  li x2, 0xffffffff
  sll x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 112
  li x28, 112
  li x1, 0x1
  li x2, 0x7
  sll x3, x1, x2
  li x29, 0x80
  bne x3, x29, fail
  # case 113
  li x28, 113
  li x1, 0x2
  li x2, 0x0
  sll x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 114
  li x28, 114
  li x1, 0x2
  li x2, 0x1
  sll x3, x1, x2
  li x29, 0x4
  bne x3, x29, fail
  # case 115
  li x28, 115
  li x1, 0x2
  li x2, 0x1f
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 116
  li x28, 116
  li x1, 0x2
  li x2, 0x80000000
  sll x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 117
  li x28, 117
  li x1, 0x2
  li x2, 0xffffffff
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 118
  li x28, 118
  li x1, 0x2
  li x2, 0x7
  sll x3, x1, x2
  li x29, 0x100
  bne x3, x29, fail
  # case 119
  li x28, 119
  li x1, 0x7fffffff
  li x2, 0x0
  sll x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 120
  li x28, 120
  li x1, 0x7fffffff
  li x2, 0x1
  sll x3, x1, x2
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 121
  li x28, 121
  li x1, 0x7fffffff
  li x2, 0x1f
  sll x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 122
  li x28, 122
  li x1, 0x7fffffff
  li x2, 0x80000000
  sll x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 123
  li x28, 123
  li x1, 0x7fffffff
  li x2, 0xffffffff
  sll x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 124
  li x28, 124
  li x1, 0x7fffffff
  li x2, 0x7
  sll x3, x1, x2
  li x29, 0xffffff80
  bne x3, x29, fail
  # case 125
  li x28, 125
  li x1, 0x80000000
  li x2, 0x0
  sll x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 126
  li x28, 126
  li x1, 0x80000000
  li x2, 0x1
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 127
  li x28, 127
  li x1, 0x80000000
  li x2, 0x1f
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 128
  li x28, 128
  li x1, 0x80000000
  li x2, 0x80000000
  sll x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 129
  li x28, 129
  li x1, 0x80000000
  li x2, 0xffffffff
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 130
  li x28, 130
  li x1, 0x80000000
  li x2, 0x7
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 131
  li x28, 131
  li x1, 0xffffffff
  li x2, 0x0
  sll x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 132
  li x28, 132
  li x1, 0xffffffff
  li x2, 0x1
  sll x3, x1, x2
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 133
  li x28, 133
  li x1, 0xffffffff
  li x2, 0x1f
  sll x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 134
  li x28, 134
  li x1, 0xffffffff
  li x2, 0x80000000
  sll x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 135
  li x28, 135
  li x1, 0xffffffff
  li x2, 0xffffffff
  sll x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 136
  li x28, 136
  li x1, 0xffffffff
  li x2, 0x7
  sll x3, x1, x2
  li x29, 0xffffff80
  bne x3, x29, fail
  # case 137
  li x28, 137
  li x1, 0x12345678
  li x2, 0x0
  sll x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 138
  li x28, 138
  li x1, 0x12345678
  li x2, 0x1
  sll x3, x1, x2
  li x29, 0x2468acf0
  bne x3, x29, fail
  # case 139
  li x28, 139
  li x1, 0x12345678
  li x2, 0x1f
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 140
  li x28, 140
  li x1, 0x12345678
  li x2, 0x80000000
  sll x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 141
  li x28, 141
  li x1, 0x12345678
  li x2, 0xffffffff
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 142
  li x28, 142
  li x1, 0x12345678
  li x2, 0x7
  sll x3, x1, x2
  li x29, 0x1a2b3c00
  bne x3, x29, fail
  # case 143
  li x28, 143
  li x1, 0xfedcba98
  li x2, 0x0
  sll x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 144
  li x28, 144
  li x1, 0xfedcba98
  li x2, 0x1
  sll x3, x1, x2
  li x29, 0xfdb97530
  bne x3, x29, fail
  # case 145
  li x28, 145
  li x1, 0xfedcba98
  li x2, 0x1f
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 146
  li x28, 146
  li x1, 0xfedcba98
  li x2, 0x80000000
  sll x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 147
  li x28, 147
  li x1, 0xfedcba98
  li x2, 0xffffffff
  sll x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 148
  li x28, 148
  li x1, 0xfedcba98
  li x2, 0x7
  sll x3, x1, x2
  li x29, 0x6e5d4c00
  bne x3, x29, fail
  # case 149
  li x28, 149
  li x5, 0x55
  sll x5, x5, x5
  li x29, 0xaa00000
  bne x5, x29, fail
  # case 150
  li x28, 150
  li x1, 9
  li x2, 3
  sll x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 151
  li x28, 151
  li x1, 0x0
  li x2, 0x0
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 152
  li x28, 152
  li x1, 0x0
  li x2, 0x1
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 153
  li x28, 153
  li x1, 0x0
  li x2, 0x1f
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 154
  li x28, 154
  li x1, 0x0
  li x2, 0x80000000
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 155
  li x28, 155
  li x1, 0x0
  li x2, 0xffffffff
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 156
  li x28, 156
  li x1, 0x0
  li x2, 0x7
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 157
  li x28, 157
  li x1, 0x1
  li x2, 0x0
  srl x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 158
  li x28, 158
  li x1, 0x1
  li x2, 0x1
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 159
  li x28, 159
  li x1, 0x1
  li x2, 0x1f
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 160
  li x28, 160
  li x1, 0x1
  li x2, 0x80000000
  srl x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 161
  li x28, 161
  li x1, 0x1
  li x2, 0xffffffff
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 162
  li x28, 162
  li x1, 0x1
  li x2, 0x7
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 163
  li x28, 163
  li x1, 0x2
  li x2, 0x0
  srl x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 164
  li x28, 164
  li x1, 0x2
  li x2, 0x1
  srl x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 165
  li x28, 165
  li x1, 0x2
  li x2, 0x1f
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 166
  li x28, 166
  li x1, 0x2
  li x2, 0x80000000
  srl x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 167
  li x28, 167
  li x1, 0x2
  li x2, 0xffffffff
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 168
  li x28, 168
  li x1, 0x2
  li x2, 0x7
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 169
  li x28, 169
  li x1, 0x7fffffff
  li x2, 0x0
  srl x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 170
  li x28, 170
  li x1, 0x7fffffff
  li x2, 0x1
  srl x3, x1, x2
  li x29, 0x3fffffff
  bne x3, x29, fail
  # case 171
  li x28, 171
  li x1, 0x7fffffff
  li x2, 0x1f
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 172
  li x28, 172
  li x1, 0x7fffffff
  li x2, 0x80000000
  srl x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 173
  li x28, 173
  li x1, 0x7fffffff
  li x2, 0xffffffff
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 174
  li x28, 174
  li x1, 0x7fffffff
  li x2, 0x7
  srl x3, x1, x2
  li x29, 0xffffff
  bne x3, x29, fail
  # case 175
  li x28, 175
  li x1, 0x80000000
  li x2, 0x0
  srl x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 176
  li x28, 176
  li x1, 0x80000000
  li x2, 0x1
  srl x3, x1, x2
  li x29, 0x40000000
  bne x3, x29, fail
  # case 177
  li x28, 177
  li x1, 0x80000000
  li x2, 0x1f
  srl x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 178
  li x28, 178
  li x1, 0x80000000
  li x2, 0x80000000
  srl x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 179
  li x28, 179
  li x1, 0x80000000
  li x2, 0xffffffff
  srl x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 180
  li x28, 180
  li x1, 0x80000000
  li x2, 0x7
  srl x3, x1, x2
  li x29, 0x1000000
  bne x3, x29, fail
  # case 181
  li x28, 181
  li x1, 0xffffffff
  li x2, 0x0
  srl x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 182
  li x28, 182
  li x1, 0xffffffff
  li x2, 0x1
  srl x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 183
  li x28, 183
  li x1, 0xffffffff
  li x2, 0x1f
  srl x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 184
  li x28, 184
  li x1, 0xffffffff
  li x2, 0x80000000
  srl x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 185
  li x28, 185
  li x1, 0xffffffff
  li x2, 0xffffffff
  srl x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 186
  li x28, 186
  li x1, 0xffffffff
  li x2, 0x7
  srl x3, x1, x2
  li x29, 0x1ffffff
  bne x3, x29, fail
  # case 187
  li x28, 187
  li x1, 0x12345678
  li x2, 0x0
  srl x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 188
  li x28, 188
  li x1, 0x12345678
  li x2, 0x1
  srl x3, x1, x2
  li x29, 0x91a2b3c
  bne x3, x29, fail
  # case 189
  li x28, 189
  li x1, 0x12345678
  li x2, 0x1f
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 190
  li x28, 190
  li x1, 0x12345678
  li x2, 0x80000000
  srl x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 191
  li x28, 191
  li x1, 0x12345678
  li x2, 0xffffffff
  srl x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 192
  li x28, 192
  li x1, 0x12345678
  li x2, 0x7
  srl x3, x1, x2
  li x29, 0x2468ac
  bne x3, x29, fail
  # case 193
  li x28, 193
  li x1, 0xfedcba98
  li x2, 0x0
  srl x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 194
  li x28, 194
  li x1, 0xfedcba98
  li x2, 0x1
  srl x3, x1, x2
  li x29, 0x7f6e5d4c
  bne x3, x29, fail
  # case 195
  li x28, 195
  li x1, 0xfedcba98
  li x2, 0x1f
  srl x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 196
  li x28, 196
  li x1, 0xfedcba98
  li x2, 0x80000000
  srl x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 197
  li x28, 197
  li x1, 0xfedcba98
  li x2, 0xffffffff
  srl x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 198
  li x28, 198
  li x1, 0xfedcba98
  li x2, 0x7
  srl x3, x1, x2
  li x29, 0x1fdb975
  bne x3, x29, fail
  # case 199
  li x28, 199
  li x5, 0x55
  srl x5, x5, x5
  li x29, 0x0
  bne x5, x29, fail
  # case 200
  li x28, 200
  li x1, 9
  li x2, 3
  srl x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 201
  li x28, 201
  li x1, 0x0
  li x2, 0x0
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 202
  li x28, 202
  li x1, 0x0
  li x2, 0x1
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 203
  li x28, 203
  li x1, 0x0
  li x2, 0x1f
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 204
  li x28, 204
  li x1, 0x0
  li x2, 0x80000000
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 205
  li x28, 205
  li x1, 0x0
  li x2, 0xffffffff
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 206
  li x28, 206
  li x1, 0x0
  li x2, 0x7
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 207
  li x28, 207
  li x1, 0x1
  li x2, 0x0
  sra x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 208
  li x28, 208
  li x1, 0x1
  li x2, 0x1
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 209
  li x28, 209
  li x1, 0x1
  li x2, 0x1f
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 210
  li x28, 210
  li x1, 0x1
  li x2, 0x80000000
  sra x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 211
  li x28, 211
  li x1, 0x1
  li x2, 0xffffffff
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 212
  li x28, 212
  li x1, 0x1
  li x2, 0x7
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 213
  li x28, 213
  li x1, 0x2
  li x2, 0x0
  sra x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 214
  li x28, 214
  li x1, 0x2
  li x2, 0x1
  sra x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 215
  li x28, 215
  li x1, 0x2
  li x2, 0x1f
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 216
  li x28, 216
  li x1, 0x2
  li x2, 0x80000000
  sra x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 217
  li x28, 217
  li x1, 0x2
  li x2, 0xffffffff
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 218
  li x28, 218
  li x1, 0x2
  li x2, 0x7
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 219
  li x28, 219
  li x1, 0x7fffffff
  li x2, 0x0
  sra x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 220
  li x28, 220
  li x1, 0x7fffffff
  li x2, 0x1
  sra x3, x1, x2
  li x29, 0x3fffffff
  bne x3, x29, fail
  # case 221
  li x28, 221
  li x1, 0x7fffffff
  li x2, 0x1f
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 222
  li x28, 222
  li x1, 0x7fffffff
  li x2, 0x80000000
  sra x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 223
  li x28, 223
  li x1, 0x7fffffff
  li x2, 0xffffffff
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 224
  li x28, 224
  li x1, 0x7fffffff
  li x2, 0x7
  sra x3, x1, x2
  li x29, 0xffffff
  bne x3, x29, fail
  # case 225
  li x28, 225
  li x1, 0x80000000
  li x2, 0x0
  sra x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 226
  li x28, 226
  li x1, 0x80000000
  li x2, 0x1
  sra x3, x1, x2
  li x29, 0xc0000000
  bne x3, x29, fail
  # case 227
  li x28, 227
  li x1, 0x80000000
  li x2, 0x1f
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 228
  li x28, 228
  li x1, 0x80000000
  li x2, 0x80000000
  sra x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 229
  li x28, 229
  li x1, 0x80000000
  li x2, 0xffffffff
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 230
  li x28, 230
  li x1, 0x80000000
  li x2, 0x7
  sra x3, x1, x2
  li x29, 0xff000000
  bne x3, x29, fail
  # case 231
  li x28, 231
  li x1, 0xffffffff
  li x2, 0x0
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 232
  li x28, 232
  li x1, 0xffffffff
  li x2, 0x1
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 233
  li x28, 233
  li x1, 0xffffffff
  li x2, 0x1f
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 234
  li x28, 234
  li x1, 0xffffffff
  li x2, 0x80000000
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 235
  li x28, 235
  li x1, 0xffffffff
  li x2, 0xffffffff
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 236
  li x28, 236
  li x1, 0xffffffff
  li x2, 0x7
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 237
  li x28, 237
  li x1, 0x12345678
  li x2, 0x0
  sra x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 238
  li x28, 238
  li x1, 0x12345678
  li x2, 0x1
  sra x3, x1, x2
  li x29, 0x91a2b3c
  bne x3, x29, fail
  # case 239
  li x28, 239
  li x1, 0x12345678
  li x2, 0x1f
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 240
  li x28, 240
  li x1, 0x12345678
  li x2, 0x80000000
  sra x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 241
  li x28, 241
  li x1, 0x12345678
  li x2, 0xffffffff
  sra x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 242
  li x28, 242
  li x1, 0x12345678
  li x2, 0x7
  sra x3, x1, x2
  li x29, 0x2468ac
  bne x3, x29, fail
  # case 243
  li x28, 243
  li x1, 0xfedcba98
  li x2, 0x0
  sra x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 244
  li x28, 244
  li x1, 0xfedcba98
  li x2, 0x1
  sra x3, x1, x2
  li x29, 0xff6e5d4c
  bne x3, x29, fail
  # case 245
  li x28, 245
  li x1, 0xfedcba98
  li x2, 0x1f
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 246
  li x28, 246
  li x1, 0xfedcba98
  li x2, 0x80000000
  sra x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 247
  li x28, 247
  li x1, 0xfedcba98
  li x2, 0xffffffff
  sra x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 248
  li x28, 248
  li x1, 0xfedcba98
  li x2, 0x7
  sra x3, x1, x2
  li x29, 0xfffdb975
  bne x3, x29, fail
  # case 249
  li x28, 249
  li x5, 0x55
  sra x5, x5, x5
  li x29, 0x0
  bne x5, x29, fail
  # case 250
  li x28, 250
  li x1, 9
  li x2, 3
  sra x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 251
  li x28, 251
  li x1, 0x0
  li x2, 0x0
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 252
  li x28, 252
  li x1, 0x0
  li x2, 0x1
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 253
  li x28, 253
  li x1, 0x0
  li x2, 0x1f
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 254
  li x28, 254
  li x1, 0x0
  li x2, 0x80000000
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 255
  li x28, 255
  li x1, 0x0
  li x2, 0xffffffff
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 256
  li x28, 256
  li x1, 0x0
  li x2, 0x7
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 257
  li x28, 257
  li x1, 0x1
  li x2, 0x0
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 258
  li x28, 258
  li x1, 0x1
  li x2, 0x1
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 259
  li x28, 259
  li x1, 0x1
  li x2, 0x1f
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 260
  li x28, 260
  li x1, 0x1
  li x2, 0x80000000
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 261
  li x28, 261
  li x1, 0x1
  li x2, 0xffffffff
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 262
  li x28, 262
  li x1, 0x1
  li x2, 0x7
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 263
  li x28, 263
  li x1, 0x2
  li x2, 0x0
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 264
  li x28, 264
  li x1, 0x2
  li x2, 0x1
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 265
  li x28, 265
  li x1, 0x2
  li x2, 0x1f
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 266
  li x28, 266
  li x1, 0x2
  li x2, 0x80000000
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 267
  li x28, 267
  li x1, 0x2
  li x2, 0xffffffff
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 268
  li x28, 268
  li x1, 0x2
  li x2, 0x7
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 269
  li x28, 269
  li x1, 0x7fffffff
  li x2, 0x0
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 270
  li x28, 270
  li x1, 0x7fffffff
  li x2, 0x1
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 271
  li x28, 271
  li x1, 0x7fffffff
  li x2, 0x1f
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 272
  li x28, 272
  li x1, 0x7fffffff
  li x2, 0x80000000
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 273
  li x28, 273
  li x1, 0x7fffffff
  li x2, 0xffffffff
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 274
  li x28, 274
  li x1, 0x7fffffff
  li x2, 0x7
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 275
  li x28, 275
  li x1, 0x80000000
  li x2, 0x0
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 276
  li x28, 276
  li x1, 0x80000000
  li x2, 0x1
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 277
  li x28, 277
  li x1, 0x80000000
  li x2, 0x1f
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 278
  li x28, 278
  li x1, 0x80000000
  li x2, 0x80000000
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 279
  li x28, 279
  li x1, 0x80000000
  li x2, 0xffffffff
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 280
  li x28, 280
  li x1, 0x80000000
  li x2, 0x7
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 281
  li x28, 281
  li x1, 0xffffffff
  li x2, 0x0
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 282
  li x28, 282
  li x1, 0xffffffff
  li x2, 0x1
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 283
  li x28, 283
  li x1, 0xffffffff
  li x2, 0x1f
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 284
  li x28, 284
  li x1, 0xffffffff
  li x2, 0x80000000
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 285
  li x28, 285
  li x1, 0xffffffff
  li x2, 0xffffffff
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 286
  li x28, 286
  li x1, 0xffffffff
  li x2, 0x7
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 287
  li x28, 287
  li x1, 0x12345678
  li x2, 0x0
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 288
  li x28, 288
  li x1, 0x12345678
  li x2, 0x1
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 289
  li x28, 289
  li x1, 0x12345678
  li x2, 0x1f
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 290
  li x28, 290
  li x1, 0x12345678
  li x2, 0x80000000
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 291
  li x28, 291
  li x1, 0x12345678
  li x2, 0xffffffff
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 292
  li x28, 292
  li x1, 0x12345678
  li x2, 0x7
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 293
  li x28, 293
  li x1, 0xfedcba98
  li x2, 0x0
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 294
  li x28, 294
  li x1, 0xfedcba98
  li x2, 0x1
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 295
  li x28, 295
  li x1, 0xfedcba98
  li x2, 0x1f
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 296
  li x28, 296
  li x1, 0xfedcba98
  li x2, 0x80000000
  slt x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 297
  li x28, 297
  li x1, 0xfedcba98
  li x2, 0xffffffff
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 298
  li x28, 298
  li x1, 0xfedcba98
  li x2, 0x7
  slt x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 299
  li x28, 299
  li x5, 0x55
  slt x5, x5, x5
  li x29, 0x0
  bne x5, x29, fail
  # case 300
  li x28, 300
  li x1, 9
  li x2, 3
  slt x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 301
  li x28, 301
  li x1, 0x0
  li x2, 0x0
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 302
  li x28, 302
  li x1, 0x0
  li x2, 0x1
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 303
  li x28, 303
  li x1, 0x0
  li x2, 0x1f
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 304
  li x28, 304
  li x1, 0x0
  li x2, 0x80000000
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 305
  li x28, 305
  li x1, 0x0
  li x2, 0xffffffff
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 306
  li x28, 306
  li x1, 0x0
  li x2, 0x7
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 307
  li x28, 307
  li x1, 0x1
  li x2, 0x0
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 308
  li x28, 308
  li x1, 0x1
  li x2, 0x1
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 309
  li x28, 309
  li x1, 0x1
  li x2, 0x1f
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 310
  li x28, 310
  li x1, 0x1
  li x2, 0x80000000
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 311
  li x28, 311
  li x1, 0x1
  li x2, 0xffffffff
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 312
  li x28, 312
  li x1, 0x1
  li x2, 0x7
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 313
  li x28, 313
  li x1, 0x2
  li x2, 0x0
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 314
  li x28, 314
  li x1, 0x2
  li x2, 0x1
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 315
  li x28, 315
  li x1, 0x2
  li x2, 0x1f
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 316
  li x28, 316
  li x1, 0x2
  li x2, 0x80000000
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 317
  li x28, 317
  li x1, 0x2
  li x2, 0xffffffff
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 318
  li x28, 318
  li x1, 0x2
  li x2, 0x7
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 319
  li x28, 319
  li x1, 0x7fffffff
  li x2, 0x0
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 320
  li x28, 320
  li x1, 0x7fffffff
  li x2, 0x1
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 321
  li x28, 321
  li x1, 0x7fffffff
  li x2, 0x1f
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 322
  li x28, 322
  li x1, 0x7fffffff
  li x2, 0x80000000
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 323
  li x28, 323
  li x1, 0x7fffffff
  li x2, 0xffffffff
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 324
  li x28, 324
  li x1, 0x7fffffff
  li x2, 0x7
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 325
  li x28, 325
  li x1, 0x80000000
  li x2, 0x0
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 326
  li x28, 326
  li x1, 0x80000000
  li x2, 0x1
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 327
  li x28, 327
  li x1, 0x80000000
  li x2, 0x1f
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 328
  li x28, 328
  li x1, 0x80000000
  li x2, 0x80000000
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 329
  li x28, 329
  li x1, 0x80000000
  li x2, 0xffffffff
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 330
  li x28, 330
  li x1, 0x80000000
  li x2, 0x7
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 331
  li x28, 331
  li x1, 0xffffffff
  li x2, 0x0
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 332
  li x28, 332
  li x1, 0xffffffff
  li x2, 0x1
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 333
  li x28, 333
  li x1, 0xffffffff
  li x2, 0x1f
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 334
  li x28, 334
  li x1, 0xffffffff
  li x2, 0x80000000
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 335
  li x28, 335
  li x1, 0xffffffff
  li x2, 0xffffffff
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 336
  li x28, 336
  li x1, 0xffffffff
  li x2, 0x7
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 337
  li x28, 337
  li x1, 0x12345678
  li x2, 0x0
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 338
  li x28, 338
  li x1, 0x12345678
  li x2, 0x1
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 339
  li x28, 339
  li x1, 0x12345678
  li x2, 0x1f
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 340
  li x28, 340
  li x1, 0x12345678
  li x2, 0x80000000
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 341
  li x28, 341
  li x1, 0x12345678
  li x2, 0xffffffff
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 342
  li x28, 342
  li x1, 0x12345678
  li x2, 0x7
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 343
  li x28, 343
  li x1, 0xfedcba98
  li x2, 0x0
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 344
  li x28, 344
  li x1, 0xfedcba98
  li x2, 0x1
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 345
  li x28, 345
  li x1, 0xfedcba98
  li x2, 0x1f
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 346
  li x28, 346
  li x1, 0xfedcba98
  li x2, 0x80000000
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 347
  li x28, 347
  li x1, 0xfedcba98
  li x2, 0xffffffff
  sltu x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 348
  li x28, 348
  li x1, 0xfedcba98
  li x2, 0x7
  sltu x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 349
  li x28, 349
  li x5, 0x55
  sltu x5, x5, x5
  li x29, 0x0
  bne x5, x29, fail
  # case 350
  li x28, 350
  li x1, 9
  li x2, 3
  sltu x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 351
  li x28, 351
  li x1, 0x0
  li x2, 0x0
  xor x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 352
  li x28, 352
  li x1, 0x0
  li x2, 0x1
  xor x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 353
  li x28, 353
  li x1, 0x0
  li x2, 0x1f
  xor x3, x1, x2
  li x29, 0x1f
  bne x3, x29, fail
  # case 354
  li x28, 354
  li x1, 0x0
  li x2, 0x80000000
  xor x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 355
  li x28, 355
  li x1, 0x0
  li x2, 0xffffffff
  xor x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 356
  li x28, 356
  li x1, 0x0
  li x2, 0x7
  xor x3, x1, x2
  li x29, 0x7
  bne x3, x29, fail
  # case 357
  li x28, 357
  li x1, 0x1
  li x2, 0x0
  xor x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 358
  li x28, 358
  li x1, 0x1
  li x2, 0x1
  xor x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 359
  li x28, 359
  li x1, 0x1
  li x2, 0x1f
  xor x3, x1, x2
  li x29, 0x1e
  bne x3, x29, fail
  # case 360
  li x28, 360
  li x1, 0x1
  li x2, 0x80000000
  xor x3, x1, x2
  li x29, 0x80000001
  bne x3, x29, fail
  # case 361
  li x28, 361
  li x1, 0x1
  li x2, 0xffffffff
  xor x3, x1, x2
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 362
  li x28, 362
  li x1, 0x1
  li x2, 0x7
  xor x3, x1, x2
  li x29, 0x6
  bne x3, x29, fail
  # case 363
  li x28, 363
  li x1, 0x2
  li x2, 0x0
  xor x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 364
  li x28, 364
  li x1, 0x2
  li x2, 0x1
  xor x3, x1, x2
  li x29, 0x3
  bne x3, x29, fail
  # case 365
  li x28, 365
  li x1, 0x2
  li x2, 0x1f
  xor x3, x1, x2
  li x29, 0x1d
  bne x3, x29, fail
  # case 366
  li x28, 366
  li x1, 0x2
  li x2, 0x80000000
  xor x3, x1, x2
  li x29, 0x80000002
  bne x3, x29, fail
  # case 367
  li x28, 367
  li x1, 0x2
  li x2, 0xffffffff
  xor x3, x1, x2
  li x29, 0xfffffffd
  bne x3, x29, fail
  # case 368
  li x28, 368
  li x1, 0x2
  li x2, 0x7
  xor x3, x1, x2
  li x29, 0x5
  bne x3, x29, fail
  # case 369
  li x28, 369
  li x1, 0x7fffffff
  li x2, 0x0
  xor x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 370
  li x28, 370
  li x1, 0x7fffffff
  li x2, 0x1
  xor x3, x1, x2
  li x29, 0x7ffffffe
  bne x3, x29, fail
  # case 371
  li x28, 371
  li x1, 0x7fffffff
  li x2, 0x1f
  xor x3, x1, x2
  li x29, 0x7fffffe0
  bne x3, x29, fail
  # case 372
  li x28, 372
  li x1, 0x7fffffff
  li x2, 0x80000000
  xor x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 373
  li x28, 373
  li x1, 0x7fffffff
  li x2, 0xffffffff
  xor x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 374
  li x28, 374
  li x1, 0x7fffffff
  li x2, 0x7
  xor x3, x1, x2
  li x29, 0x7ffffff8
  bne x3, x29, fail
  # case 375
  li x28, 375
  li x1, 0x80000000
  li x2, 0x0
  xor x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 376
  li x28, 376
  li x1, 0x80000000
  li x2, 0x1
  xor x3, x1, x2
  li x29, 0x80000001
  bne x3, x29, fail
  # case 377
  li x28, 377
  li x1, 0x80000000
  li x2, 0x1f
  xor x3, x1, x2
  li x29, 0x8000001f
  bne x3, x29, fail
  # case 378
  li x28, 378
  li x1, 0x80000000
  li x2, 0x80000000
  xor x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 379
  li x28, 379
  li x1, 0x80000000
  li x2, 0xffffffff
  xor x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 380
  li x28, 380
  li x1, 0x80000000
  li x2, 0x7
  xor x3, x1, x2
  li x29, 0x80000007
  bne x3, x29, fail
  # case 381
  li x28, 381
  li x1, 0xffffffff
  li x2, 0x0
  xor x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 382
  li x28, 382
  li x1, 0xffffffff
  li x2, 0x1
  xor x3, x1, x2
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 383
  li x28, 383
  li x1, 0xffffffff
  li x2, 0x1f
  xor x3, x1, x2
  li x29, 0xffffffe0
  bne x3, x29, fail
  # case 384
  li x28, 384
  li x1, 0xffffffff
  li x2, 0x80000000
  xor x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 385
  li x28, 385
  li x1, 0xffffffff
  li x2, 0xffffffff
  xor x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 386
  li x28, 386
  li x1, 0xffffffff
  li x2, 0x7
  xor x3, x1, x2
  li x29, 0xfffffff8
  bne x3, x29, fail
  # case 387
  li x28, 387
  li x1, 0x12345678
  li x2, 0x0
  xor x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 388
  li x28, 388
  li x1, 0x12345678
  li x2, 0x1
  xor x3, x1, x2
  li x29, 0x12345679
  bne x3, x29, fail
  # case 389
  li x28, 389
  li x1, 0x12345678
  li x2, 0x1f
  xor x3, x1, x2
  li x29, 0x12345667
  bne x3, x29, fail
  # case 390
  li x28, 390
  li x1, 0x12345678
  li x2, 0x80000000
  xor x3, x1, x2
  li x29, 0x92345678
  bne x3, x29, fail
  # case 391
  li x28, 391
  li x1, 0x12345678
  li x2, 0xffffffff
  xor x3, x1, x2
  li x29, 0xedcba987
  bne x3, x29, fail
  # case 392
  li x28, 392
  li x1, 0x12345678
  li x2, 0x7
  xor x3, x1, x2
  li x29, 0x1234567f
  bne x3, x29, fail
  # case 393
  li x28, 393
  li x1, 0xfedcba98
  li x2, 0x0
  xor x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 394
  li x28, 394
  li x1, 0xfedcba98
  li x2, 0x1
  xor x3, x1, x2
  li x29, 0xfedcba99
  bne x3, x29, fail
  # case 395
  li x28, 395
  li x1, 0xfedcba98
  li x2, 0x1f
  xor x3, x1, x2
  li x29, 0xfedcba87
  bne x3, x29, fail
  # case 396
  li x28, 396
  li x1, 0xfedcba98
  li x2, 0x80000000
  xor x3, x1, x2
  li x29, 0x7edcba98
  bne x3, x29, fail
  # case 397
  li x28, 397
  li x1, 0xfedcba98
  li x2, 0xffffffff
  xor x3, x1, x2
  li x29, 0x1234567
  bne x3, x29, fail
  # case 398
  li x28, 398
  li x1, 0xfedcba98
  li x2, 0x7
  xor x3, x1, x2
  li x29, 0xfedcba9f
  bne x3, x29, fail
  # case 399
  li x28, 399
  li x5, 0x55
  xor x5, x5, x5
  li x29, 0x0
  bne x5, x29, fail
  # case 400
  li x28, 400
  li x1, 9
  li x2, 3
  xor x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 401
  li x28, 401
  li x1, 0x0
  li x2, 0x0
  or x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 402
  li x28, 402
  li x1, 0x0
  li x2, 0x1
  or x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 403
  li x28, 403
  li x1, 0x0
  li x2, 0x1f
  or x3, x1, x2
  li x29, 0x1f
  bne x3, x29, fail
  # case 404
  li x28, 404
  li x1, 0x0
  li x2, 0x80000000
  or x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 405
  li x28, 405
  li x1, 0x0
  li x2, 0xffffffff
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 406
  li x28, 406
  li x1, 0x0
  li x2, 0x7
  or x3, x1, x2
  li x29, 0x7
  bne x3, x29, fail
  # case 407
  li x28, 407
  li x1, 0x1
  li x2, 0x0
  or x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 408
  li x28, 408
  li x1, 0x1
  li x2, 0x1
  or x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 409
  li x28, 409
  li x1, 0x1
  li x2, 0x1f
  or x3, x1, x2
  li x29, 0x1f
  bne x3, x29, fail
  # case 410
  li x28, 410
  li x1, 0x1
  li x2, 0x80000000
  or x3, x1, x2
  li x29, 0x80000001
  bne x3, x29, fail
  # case 411
  li x28, 411
  li x1, 0x1
  li x2, 0xffffffff
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 412
  li x28, 412
  li x1, 0x1
  li x2, 0x7
  or x3, x1, x2
  li x29, 0x7
  bne x3, x29, fail
  # case 413
  li x28, 413
  li x1, 0x2
  li x2, 0x0
  or x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 414
  li x28, 414
  li x1, 0x2
  li x2, 0x1
  or x3, x1, x2
  li x29, 0x3
  bne x3, x29, fail
  # case 415
  li x28, 415
  li x1, 0x2
  li x2, 0x1f
  or x3, x1, x2
  li x29, 0x1f
  bne x3, x29, fail
  # case 416
  li x28, 416
  li x1, 0x2
  li x2, 0x80000000
  or x3, x1, x2
  li x29, 0x80000002
  bne x3, x29, fail
  # case 417
  li x28, 417
  li x1, 0x2
  li x2, 0xffffffff
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 418
  li x28, 418
  li x1, 0x2
  li x2, 0x7
  or x3, x1, x2
  li x29, 0x7
  bne x3, x29, fail
  # case 419
  li x28, 419
  li x1, 0x7fffffff
  li x2, 0x0
  or x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 420
  li x28, 420
  li x1, 0x7fffffff
  li x2, 0x1
  or x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 421
  li x28, 421
  li x1, 0x7fffffff
  li x2, 0x1f
  or x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 422
  li x28, 422
  li x1, 0x7fffffff
  li x2, 0x80000000
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 423
  li x28, 423
  li x1, 0x7fffffff
  li x2, 0xffffffff
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 424
  li x28, 424
  li x1, 0x7fffffff
  li x2, 0x7
  or x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 425
  li x28, 425
  li x1, 0x80000000
  li x2, 0x0
  or x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 426
  li x28, 426
  li x1, 0x80000000
  li x2, 0x1
  or x3, x1, x2
  li x29, 0x80000001
  bne x3, x29, fail
  # case 427
  li x28, 427
  li x1, 0x80000000
  li x2, 0x1f
  or x3, x1, x2
  li x29, 0x8000001f
  bne x3, x29, fail
  # case 428
  li x28, 428
  li x1, 0x80000000
  li x2, 0x80000000
  or x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 429
  li x28, 429
  li x1, 0x80000000
  li x2, 0xffffffff
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 430
  li x28, 430
  li x1, 0x80000000
  li x2, 0x7
  or x3, x1, x2
  li x29, 0x80000007
  bne x3, x29, fail
  # case 431
  li x28, 431
  li x1, 0xffffffff
  li x2, 0x0
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 432
  li x28, 432
  li x1, 0xffffffff
  li x2, 0x1
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 433
  li x28, 433
  li x1, 0xffffffff
  li x2, 0x1f
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 434
  li x28, 434
  li x1, 0xffffffff
  li x2, 0x80000000
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 435
  li x28, 435
  li x1, 0xffffffff
  li x2, 0xffffffff
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 436
  li x28, 436
  li x1, 0xffffffff
  li x2, 0x7
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 437
  li x28, 437
  li x1, 0x12345678
  li x2, 0x0
  or x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 438
  li x28, 438
  li x1, 0x12345678
  li x2, 0x1
  or x3, x1, x2
  li x29, 0x12345679
  bne x3, x29, fail
  # case 439
  li x28, 439
  li x1, 0x12345678
  li x2, 0x1f
  or x3, x1, x2
  li x29, 0x1234567f
  bne x3, x29, fail
  # case 440
  li x28, 440
  li x1, 0x12345678
  li x2, 0x80000000
  or x3, x1, x2
  li x29, 0x92345678
  bne x3, x29, fail
  # case 441
  li x28, 441
  li x1, 0x12345678
  li x2, 0xffffffff
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 442
  li x28, 442
  li x1, 0x12345678
  li x2, 0x7
  or x3, x1, x2
  li x29, 0x1234567f
  bne x3, x29, fail
  # case 443
  li x28, 443
  li x1, 0xfedcba98
  li x2, 0x0
  or x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 444
  li x28, 444
  li x1, 0xfedcba98
  li x2, 0x1
  or x3, x1, x2
  li x29, 0xfedcba99
  bne x3, x29, fail
  # case 445
  li x28, 445
  li x1, 0xfedcba98
  li x2, 0x1f
  or x3, x1, x2
  li x29, 0xfedcba9f
  bne x3, x29, fail
  # case 446
  li x28, 446
  li x1, 0xfedcba98
  li x2, 0x80000000
  or x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 447
  li x28, 447
  li x1, 0xfedcba98
  li x2, 0xffffffff
  or x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 448
  li x28, 448
  li x1, 0xfedcba98
  li x2, 0x7
  or x3, x1, x2
  li x29, 0xfedcba9f
  bne x3, x29, fail
  # case 449
  li x28, 449
  li x5, 0x55
  or x5, x5, x5
  li x29, 0x55
  bne x5, x29, fail
  # case 450
  li x28, 450
  li x1, 9
  li x2, 3
  or x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 451
  li x28, 451
  li x1, 0x0
  li x2, 0x0
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 452
  li x28, 452
  li x1, 0x0
  li x2, 0x1
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 453
  li x28, 453
  li x1, 0x0
  li x2, 0x1f
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 454
  li x28, 454
  li x1, 0x0
  li x2, 0x80000000
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 455
  li x28, 455
  li x1, 0x0
  li x2, 0xffffffff
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 456
  li x28, 456
  li x1, 0x0
  li x2, 0x7
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 457
  li x28, 457
  li x1, 0x1
  li x2, 0x0
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 458
  li x28, 458
  li x1, 0x1
  li x2, 0x1
  and x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 459
  li x28, 459
  li x1, 0x1
  li x2, 0x1f
  and x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 460
  li x28, 460
  li x1, 0x1
  li x2, 0x80000000
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 461
  li x28, 461
  li x1, 0x1
  li x2, 0xffffffff
  and x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 462
  li x28, 462
  li x1, 0x1
  li x2, 0x7
  and x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 463
  li x28, 463
  li x1, 0x2
  li x2, 0x0
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 464
  li x28, 464
  li x1, 0x2
  li x2, 0x1
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 465
  li x28, 465
  li x1, 0x2
  li x2, 0x1f
  and x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 466
  li x28, 466
  li x1, 0x2
  li x2, 0x80000000
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 467
  li x28, 467
  li x1, 0x2
  li x2, 0xffffffff
  and x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 468
  li x28, 468
  li x1, 0x2
  li x2, 0x7
  and x3, x1, x2
  li x29, 0x2
  bne x3, x29, fail
  # case 469
  li x28, 469
  li x1, 0x7fffffff
  li x2, 0x0
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 470
  li x28, 470
  li x1, 0x7fffffff
  li x2, 0x1
  and x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 471
  li x28, 471
  li x1, 0x7fffffff
  li x2, 0x1f
  and x3, x1, x2
  li x29, 0x1f
  bne x3, x29, fail
  # case 472
  li x28, 472
  li x1, 0x7fffffff
  li x2, 0x80000000
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 473
  li x28, 473
  li x1, 0x7fffffff
  li x2, 0xffffffff
  and x3, x1, x2
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 474
  li x28, 474
  li x1, 0x7fffffff
  li x2, 0x7
  and x3, x1, x2
  li x29, 0x7
  bne x3, x29, fail
  # case 475
  li x28, 475
  li x1, 0x80000000
  li x2, 0x0
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 476
  li x28, 476
  li x1, 0x80000000
  li x2, 0x1
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 477
  li x28, 477
  li x1, 0x80000000
  li x2, 0x1f
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 478
  li x28, 478
  li x1, 0x80000000
  li x2, 0x80000000
  and x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 479
  li x28, 479
  li x1, 0x80000000
  li x2, 0xffffffff
  and x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 480
  li x28, 480
  li x1, 0x80000000
  li x2, 0x7
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 481
  li x28, 481
  li x1, 0xffffffff
  li x2, 0x0
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 482
  li x28, 482
  li x1, 0xffffffff
  li x2, 0x1
  and x3, x1, x2
  li x29, 0x1
  bne x3, x29, fail
  # case 483
  li x28, 483
  li x1, 0xffffffff
  li x2, 0x1f
  and x3, x1, x2
  li x29, 0x1f
  bne x3, x29, fail
  # case 484
  li x28, 484
  li x1, 0xffffffff
  li x2, 0x80000000
  and x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 485
  li x28, 485
  li x1, 0xffffffff
  li x2, 0xffffffff
  and x3, x1, x2
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 486
  li x28, 486
  li x1, 0xffffffff
  li x2, 0x7
  and x3, x1, x2
  li x29, 0x7
  bne x3, x29, fail
  # case 487
  li x28, 487
  li x1, 0x12345678
  li x2, 0x0
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 488
  li x28, 488
  li x1, 0x12345678
  li x2, 0x1
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 489
  li x28, 489
  li x1, 0x12345678
  li x2, 0x1f
  and x3, x1, x2
  li x29, 0x18
  bne x3, x29, fail
  # case 490
  li x28, 490
  li x1, 0x12345678
  li x2, 0x80000000
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 491
  li x28, 491
  li x1, 0x12345678
  li x2, 0xffffffff
  and x3, x1, x2
  li x29, 0x12345678
  bne x3, x29, fail
  # case 492
  li x28, 492
  li x1, 0x12345678
  li x2, 0x7
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 493
  li x28, 493
  li x1, 0xfedcba98
  li x2, 0x0
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 494
  li x28, 494
  li x1, 0xfedcba98
  li x2, 0x1
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 495
  li x28, 495
  li x1, 0xfedcba98
  li x2, 0x1f
  and x3, x1, x2
  li x29, 0x18
  bne x3, x29, fail
  # case 496
  li x28, 496
  li x1, 0xfedcba98
  li x2, 0x80000000
  and x3, x1, x2
  li x29, 0x80000000
  bne x3, x29, fail
  # case 497
  li x28, 497
  li x1, 0xfedcba98
  li x2, 0xffffffff
  and x3, x1, x2
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 498
  li x28, 498
  li x1, 0xfedcba98
  li x2, 0x7
  and x3, x1, x2
  li x29, 0x0
  bne x3, x29, fail
  # case 499
  li x28, 499
  li x5, 0x55
  and x5, x5, x5
  li x29, 0x55
  bne x5, x29, fail
  # case 500
  li x28, 500
  li x1, 9
  li x2, 3
  and x0, x1, x2
  li x29, 0x0
  bne x0, x29, fail
  # case 501
  li x28, 501
  li x1, 0x0
  addi x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 502
  li x28, 502
  li x1, 0x0
  addi x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 503
  li x28, 503
  li x1, 0x0
  addi x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 504
  li x28, 504
  li x1, 0x0
  addi x3, x1, 2047
  li x29, 0x7ff
  bne x3, x29, fail
  # case 505
  li x28, 505
  li x1, 0x0
  addi x3, x1, -2048
  li x29, 0xfffff800
  bne x3, x29, fail
  # case 506
  li x28, 506
  li x1, 0x0
  addi x3, x1, 2032
  li x29, 0x7f0
  bne x3, x29, fail
  # case 507
  li x28, 507
  li x1, 0x0
  addi x3, x1, 31
  li x29, 0x1f
  bne x3, x29, fail
  # case 508
  li x28, 508
  li x1, 0x0
  addi x3, x1, 5
  li x29, 0x5
  bne x3, x29, fail
  # case 509
  li x28, 509
  li x1, 0x1
  addi x3, x1, 0
  li x29, 0x1
  bne x3, x29, fail
  # case 510
  li x28, 510
  li x1, 0x1
  addi x3, x1, 1
  li x29, 0x2
  bne x3, x29, fail
  # case 511
  li x28, 511
  li x1, 0x1
  addi x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 512
  li x28, 512
  li x1, 0x1
  addi x3, x1, 2047
  li x29, 0x800
  bne x3, x29, fail
  # case 513
  li x28, 513
  li x1, 0x1
  addi x3, x1, -2048
  li x29, 0xfffff801
  bne x3, x29, fail
  # case 514
  li x28, 514
  li x1, 0x1
  addi x3, x1, 2032
  li x29, 0x7f1
  bne x3, x29, fail
  # case 515
  li x28, 515
  li x1, 0x1
  addi x3, x1, 31
  li x29, 0x20
  bne x3, x29, fail
  # case 516
  li x28, 516
  li x1, 0x1
  addi x3, x1, 5
  li x29, 0x6
  bne x3, x29, fail
  # case 517
  li x28, 517
  li x1, 0x2
  addi x3, x1, 0
  li x29, 0x2
  bne x3, x29, fail
  # case 518
  li x28, 518
  li x1, 0x2
  addi x3, x1, 1
  li x29, 0x3
  bne x3, x29, fail
  # case 519
  li x28, 519
  li x1, 0x2
  addi x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 520
  li x28, 520
  li x1, 0x2
  addi x3, x1, 2047
  li x29, 0x801
  bne x3, x29, fail
  # case 521
  li x28, 521
  li x1, 0x2
  addi x3, x1, -2048
  li x29, 0xfffff802
  bne x3, x29, fail
  # case 522
  li x28, 522
  li x1, 0x2
  addi x3, x1, 2032
  li x29, 0x7f2
  bne x3, x29, fail
  # case 523
  li x28, 523
  li x1, 0x2
  addi x3, x1, 31
  li x29, 0x21
  bne x3, x29, fail
  # case 524
  li x28, 524
  li x1, 0x2
  addi x3, x1, 5
  li x29, 0x7
  bne x3, x29, fail
  # case 525
  li x28, 525
  li x1, 0x7fffffff
  addi x3, x1, 0
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 526
  li x28, 526
  li x1, 0x7fffffff
  addi x3, x1, 1
  li x29, 0x80000000
  bne x3, x29, fail
  # case 527
  li x28, 527
  li x1, 0x7fffffff
  addi x3, x1, -1
  li x29, 0x7ffffffe
  bne x3, x29, fail
  # case 528
  li x28, 528
  li x1, 0x7fffffff
  addi x3, x1, 2047
  li x29, 0x800007fe
  bne x3, x29, fail
  # case 529
  li x28, 529
  li x1, 0x7fffffff
  addi x3, x1, -2048
  li x29, 0x7ffff7ff
  bne x3, x29, fail
  # case 530
  li x28, 530
  li x1, 0x7fffffff
  addi x3, x1, 2032
  li x29, 0x800007ef
  bne x3, x29, fail
  # case 531
  li x28, 531
  li x1, 0x7fffffff
  addi x3, x1, 31
  li x29, 0x8000001e
  bne x3, x29, fail
  # case 532
  li x28, 532
  li x1, 0x7fffffff
  addi x3, x1, 5
  li x29, 0x80000004
  bne x3, x29, fail
  # case 533
  li x28, 533
  li x1, 0x80000000
  addi x3, x1, 0
  li x29, 0x80000000
  bne x3, x29, fail
  # case 534
  li x28, 534
  li x1, 0x80000000
  addi x3, x1, 1
  li x29, 0x80000001
  bne x3, x29, fail
  # case 535
  li x28, 535
  li x1, 0x80000000
  addi x3, x1, -1
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 536
  li x28, 536
  li x1, 0x80000000
  addi x3, x1, 2047
  li x29, 0x800007ff
  bne x3, x29, fail
  # case 537
  li x28, 537
  li x1, 0x80000000
  addi x3, x1, -2048
  li x29, 0x7ffff800
  bne x3, x29, fail
  # case 538
  li x28, 538
  li x1, 0x80000000
  addi x3, x1, 2032
  li x29, 0x800007f0
  bne x3, x29, fail
  # case 539
  li x28, 539
  li x1, 0x80000000
  addi x3, x1, 31
  li x29, 0x8000001f
  bne x3, x29, fail
  # case 540
  li x28, 540
  li x1, 0x80000000
  addi x3, x1, 5
  li x29, 0x80000005
  bne x3, x29, fail
  # case 541
  li x28, 541
  li x1, 0xffffffff
  addi x3, x1, 0
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 542
  li x28, 542
  li x1, 0xffffffff
  addi x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 543
  li x28, 543
  li x1, 0xffffffff
  addi x3, x1, -1
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 544
  li x28, 544
  li x1, 0xffffffff
  addi x3, x1, 2047
  li x29, 0x7fe
  bne x3, x29, fail
  # case 545
  li x28, 545
  li x1, 0xffffffff
  addi x3, x1, -2048
  li x29, 0xfffff7ff
  bne x3, x29, fail
  # case 546
  li x28, 546
  li x1, 0xffffffff
  addi x3, x1, 2032
  li x29, 0x7ef
  bne x3, x29, fail
  # case 547
  li x28, 547
  li x1, 0xffffffff
  addi x3, x1, 31
  li x29, 0x1e
  bne x3, x29, fail
  # case 548
  li x28, 548
  li x1, 0xffffffff
  addi x3, x1, 5
  li x29, 0x4
  bne x3, x29, fail
  # case 549
  li x28, 549
  li x1, 0x12345678
  addi x3, x1, 0
  li x29, 0x12345678
  bne x3, x29, fail
  # case 550
  li x28, 550
  li x1, 0x12345678
  addi x3, x1, 1
  li x29, 0x12345679
  bne x3, x29, fail
  # case 551
  li x28, 551
  li x1, 0x12345678
  addi x3, x1, -1
  li x29, 0x12345677
  bne x3, x29, fail
  # case 552
  li x28, 552
  li x1, 0x12345678
  addi x3, x1, 2047
  li x29, 0x12345e77
  bne x3, x29, fail
  # case 553
  li x28, 553
  li x1, 0x12345678
  addi x3, x1, -2048
  li x29, 0x12344e78
  bne x3, x29, fail
  # case 554
  li x28, 554
  li x1, 0x12345678
  addi x3, x1, 2032
  li x29, 0x12345e68
  bne x3, x29, fail
  # case 555
  li x28, 555
  li x1, 0x12345678
  addi x3, x1, 31
  li x29, 0x12345697
  bne x3, x29, fail
  # case 556
  li x28, 556
  li x1, 0x12345678
  addi x3, x1, 5
  li x29, 0x1234567d
  bne x3, x29, fail
  # case 557
  li x28, 557
  li x1, 0xfedcba98
  addi x3, x1, 0
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 558
  li x28, 558
  li x1, 0xfedcba98
  addi x3, x1, 1
  li x29, 0xfedcba99
  bne x3, x29, fail
  # case 559
  li x28, 559
  li x1, 0xfedcba98
  addi x3, x1, -1
  li x29, 0xfedcba97
  bne x3, x29, fail
  # case 560
  li x28, 560
  li x1, 0xfedcba98
  addi x3, x1, 2047
  li x29, 0xfedcc297
  bne x3, x29, fail
  # case 561
  li x28, 561
  li x1, 0xfedcba98
  addi x3, x1, -2048
  li x29, 0xfedcb298
  bne x3, x29, fail
  # case 562
  li x28, 562
  li x1, 0xfedcba98
  addi x3, x1, 2032
  li x29, 0xfedcc288
  bne x3, x29, fail
  # case 563
  li x28, 563
  li x1, 0xfedcba98
  addi x3, x1, 31
  li x29, 0xfedcbab7
  bne x3, x29, fail
  # case 564
  li x28, 564
  li x1, 0xfedcba98
  addi x3, x1, 5
  li x29, 0xfedcba9d
  bne x3, x29, fail
  # case 565
  li x28, 565
  li x1, 0x0
  slti x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 566
  li x28, 566
  li x1, 0x0
  slti x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 567
  li x28, 567
  li x1, 0x0
  slti x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 568
  li x28, 568
  li x1, 0x0
  slti x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 569
  li x28, 569
  li x1, 0x0
  slti x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 570
  li x28, 570
  li x1, 0x0
  slti x3, x1, 2032
  li x29, 0x1
  bne x3, x29, fail
  # case 571
  li x28, 571
  li x1, 0x0
  slti x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 572
  li x28, 572
  li x1, 0x0
  slti x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 573
  li x28, 573
  li x1, 0x1
  slti x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 574
  li x28, 574
  li x1, 0x1
  slti x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 575
  li x28, 575
  li x1, 0x1
  slti x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 576
  li x28, 576
  li x1, 0x1
  slti x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 577
  li x28, 577
  li x1, 0x1
  slti x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 578
  li x28, 578
  li x1, 0x1
  slti x3, x1, 2032
  li x29, 0x1
  bne x3, x29, fail
  # case 579
  li x28, 579
  li x1, 0x1
  slti x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 580
  li x28, 580
  li x1, 0x1
  slti x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 581
  li x28, 581
  li x1, 0x2
  slti x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 582
  li x28, 582
  li x1, 0x2
  slti x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 583
  li x28, 583
  li x1, 0x2
  slti x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 584
  li x28, 584
  li x1, 0x2
  slti x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 585
  li x28, 585
  li x1, 0x2
  slti x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 586
  li x28, 586
  li x1, 0x2
  slti x3, x1, 2032
  li x29, 0x1
  bne x3, x29, fail
  # case 587
  li x28, 587
  li x1, 0x2
  slti x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 588
  li x28, 588
  li x1, 0x2
  slti x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 589
  li x28, 589
  li x1, 0x7fffffff
  slti x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 590
  li x28, 590
  li x1, 0x7fffffff
  slti x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 591
  li x28, 591
  li x1, 0x7fffffff
  slti x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 592
  li x28, 592
  li x1, 0x7fffffff
  slti x3, x1, 2047
  li x29, 0x0
  bne x3, x29, fail
  # case 593
  li x28, 593
  li x1, 0x7fffffff
  slti x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 594
  li x28, 594
  li x1, 0x7fffffff
  slti x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 595
  li x28, 595
  li x1, 0x7fffffff
  slti x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 596
  li x28, 596
  li x1, 0x7fffffff
  slti x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 597
  li x28, 597
  li x1, 0x80000000
  slti x3, x1, 0
  li x29, 0x1
  bne x3, x29, fail
  # case 598
  li x28, 598
  li x1, 0x80000000
  slti x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 599
  li x28, 599
  li x1, 0x80000000
  slti x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 600
  li x28, 600
  li x1, 0x80000000
  slti x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 601
  li x28, 601
  li x1, 0x80000000
  slti x3, x1, -2048
  li x29, 0x1
  bne x3, x29, fail
  # case 602
  li x28, 602
  li x1, 0x80000000
  slti x3, x1, 2032
  li x29, 0x1
  bne x3, x29, fail
  # case 603
  li x28, 603
  li x1, 0x80000000
  slti x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 604
  li x28, 604
  li x1, 0x80000000
  slti x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 605
  li x28, 605
  li x1, 0xffffffff
  slti x3, x1, 0
  li x29, 0x1
  bne x3, x29, fail
  # case 606
  li x28, 606
  li x1, 0xffffffff
  slti x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 607
  li x28, 607
  li x1, 0xffffffff
  slti x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 608
  li x28, 608
  li x1, 0xffffffff
  slti x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 609
  li x28, 609
  li x1, 0xffffffff
  slti x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 610
  li x28, 610
  li x1, 0xffffffff
  slti x3, x1, 2032
  li x29, 0x1
  bne x3, x29, fail
  # case 611
  li x28, 611
  li x1, 0xffffffff
  slti x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 612
  li x28, 612
  li x1, 0xffffffff
  slti x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 613
  li x28, 613
  li x1, 0x12345678
  slti x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 614
  li x28, 614
  li x1, 0x12345678
  slti x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 615
  li x28, 615
  li x1, 0x12345678
  slti x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 616
  li x28, 616
  li x1, 0x12345678
  slti x3, x1, 2047
  li x29, 0x0
  bne x3, x29, fail
  # case 617
  li x28, 617
  li x1, 0x12345678
  slti x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 618
  li x28, 618
  li x1, 0x12345678
  slti x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 619
  li x28, 619
  li x1, 0x12345678
  slti x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 620
  li x28, 620
  li x1, 0x12345678
  slti x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 621
  li x28, 621
  li x1, 0xfedcba98
  slti x3, x1, 0
  li x29, 0x1
  bne x3, x29, fail
  # case 622
  li x28, 622
  li x1, 0xfedcba98
  slti x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 623
  li x28, 623
  li x1, 0xfedcba98
  slti x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 624
  li x28, 624
  li x1, 0xfedcba98
  slti x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 625
  li x28, 625
  li x1, 0xfedcba98
  slti x3, x1, -2048
  li x29, 0x1
  bne x3, x29, fail
  # case 626
  li x28, 626
  li x1, 0xfedcba98
  slti x3, x1, 2032
  li x29, 0x1
  bne x3, x29, fail
  # case 627
  li x28, 627
  li x1, 0xfedcba98
  slti x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 628
  li x28, 628
  li x1, 0xfedcba98
  slti x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 629
  li x28, 629
  li x1, 0x0
  sltiu x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 630
  li x28, 630
  li x1, 0x0
  sltiu x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 631
  li x28, 631
  li x1, 0x0
  sltiu x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 632
  li x28, 632
  li x1, 0x0
  sltiu x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 633
  li x28, 633
  li x1, 0x0
  sltiu x3, x1, -2048
  li x29, 0x1
  bne x3, x29, fail
  # case 634
  li x28, 634
  li x1, 0x0
  sltiu x3, x1, 2032
  li x29, 0x1
  bne x3, x29, fail
  # case 635
  li x28, 635
  li x1, 0x0
  sltiu x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 636
  li x28, 636
  li x1, 0x0
  sltiu x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 637
  li x28, 637
  li x1, 0x1
  sltiu x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 638
  li x28, 638
  li x1, 0x1
  sltiu x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 639
  li x28, 639
  li x1, 0x1
  sltiu x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 640
  li x28, 640
  li x1, 0x1
  sltiu x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 641
  li x28, 641
  li x1, 0x1
  sltiu x3, x1, -2048
  li x29, 0x1
  bne x3, x29, fail
  # case 642
  li x28, 642
  li x1, 0x1
  sltiu x3, x1, 2032
  li x29, 0x1
  bne x3, x29, fail
  # case 643
  li x28, 643
  li x1, 0x1
  sltiu x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 644
  li x28, 644
  li x1, 0x1
  sltiu x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 645
  li x28, 645
  li x1, 0x2
  sltiu x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 646
  li x28, 646
  li x1, 0x2
  sltiu x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 647
  li x28, 647
  li x1, 0x2
  sltiu x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 648
  li x28, 648
  li x1, 0x2
  sltiu x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 649
  li x28, 649
  li x1, 0x2
  sltiu x3, x1, -2048
  li x29, 0x1
  bne x3, x29, fail
  # case 650
  li x28, 650
  li x1, 0x2
  sltiu x3, x1, 2032
  li x29, 0x1
  bne x3, x29, fail
  # case 651
  li x28, 651
  li x1, 0x2
  sltiu x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 652
  li x28, 652
  li x1, 0x2
  sltiu x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 653
  li x28, 653
  li x1, 0x7fffffff
  sltiu x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 654
  li x28, 654
  li x1, 0x7fffffff
  sltiu x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 655
  li x28, 655
  li x1, 0x7fffffff
  sltiu x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 656
  li x28, 656
  li x1, 0x7fffffff
  sltiu x3, x1, 2047
  li x29, 0x0
  bne x3, x29, fail
  # case 657
  li x28, 657
  li x1, 0x7fffffff
  sltiu x3, x1, -2048
  li x29, 0x1
  bne x3, x29, fail
  # case 658
  li x28, 658
  li x1, 0x7fffffff
  sltiu x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 659
  li x28, 659
  li x1, 0x7fffffff
  sltiu x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 660
  li x28, 660
  li x1, 0x7fffffff
  sltiu x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 661
  li x28, 661
  li x1, 0x80000000
  sltiu x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 662
  li x28, 662
  li x1, 0x80000000
  sltiu x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 663
  li x28, 663
  li x1, 0x80000000
  sltiu x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 664
  li x28, 664
  li x1, 0x80000000
  sltiu x3, x1, 2047
  li x29, 0x0
  bne x3, x29, fail
  # case 665
  li x28, 665
  li x1, 0x80000000
  sltiu x3, x1, -2048
  li x29, 0x1
  bne x3, x29, fail
  # case 666
  li x28, 666
  li x1, 0x80000000
  sltiu x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 667
  li x28, 667
  li x1, 0x80000000
  sltiu x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 668
  li x28, 668
  li x1, 0x80000000
  sltiu x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 669
  li x28, 669
  li x1, 0xffffffff
  sltiu x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 670
  li x28, 670
  li x1, 0xffffffff
  sltiu x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 671
  li x28, 671
  li x1, 0xffffffff
  sltiu x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 672
  li x28, 672
  li x1, 0xffffffff
  sltiu x3, x1, 2047
  li x29, 0x0
  bne x3, x29, fail
  # case 673
  li x28, 673
  li x1, 0xffffffff
  sltiu x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 674
  li x28, 674
  li x1, 0xffffffff
  sltiu x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 675
  li x28, 675
  li x1, 0xffffffff
  sltiu x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 676
  li x28, 676
  li x1, 0xffffffff
  sltiu x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 677
  li x28, 677
  li x1, 0x12345678
  sltiu x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 678
  li x28, 678
  li x1, 0x12345678
  sltiu x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 679
  li x28, 679
  li x1, 0x12345678
  sltiu x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 680
  li x28, 680
  li x1, 0x12345678
  sltiu x3, x1, 2047
  li x29, 0x0
  bne x3, x29, fail
  # case 681
  li x28, 681
  li x1, 0x12345678
  sltiu x3, x1, -2048
  li x29, 0x1
  bne x3, x29, fail
  # case 682
  li x28, 682
  li x1, 0x12345678
  sltiu x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 683
  li x28, 683
  li x1, 0x12345678
  sltiu x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 684
  li x28, 684
  li x1, 0x12345678
  sltiu x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 685
  li x28, 685
  li x1, 0xfedcba98
  sltiu x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 686
  li x28, 686
  li x1, 0xfedcba98
  sltiu x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 687
  li x28, 687
  li x1, 0xfedcba98
  sltiu x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 688
  li x28, 688
  li x1, 0xfedcba98
  sltiu x3, x1, 2047
  li x29, 0x0
  bne x3, x29, fail
  # case 689
  li x28, 689
  li x1, 0xfedcba98
  sltiu x3, x1, -2048
  li x29, 0x1
  bne x3, x29, fail
  # case 690
  li x28, 690
  li x1, 0xfedcba98
  sltiu x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 691
  li x28, 691
  li x1, 0xfedcba98
  sltiu x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 692
  li x28, 692
  li x1, 0xfedcba98
  sltiu x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 693
  li x28, 693
  li x1, 0x0
  xori x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 694
  li x28, 694
  li x1, 0x0
  xori x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 695
  li x28, 695
  li x1, 0x0
  xori x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 696
  li x28, 696
  li x1, 0x0
  xori x3, x1, 2047
  li x29, 0x7ff
  bne x3, x29, fail
  # case 697
  li x28, 697
  li x1, 0x0
  xori x3, x1, -2048
  li x29, 0xfffff800
  bne x3, x29, fail
  # case 698
  li x28, 698
  li x1, 0x0
  xori x3, x1, 2032
  li x29, 0x7f0
  bne x3, x29, fail
  # case 699
  li x28, 699
  li x1, 0x0
  xori x3, x1, 31
  li x29, 0x1f
  bne x3, x29, fail
  # case 700
  li x28, 700
  li x1, 0x0
  xori x3, x1, 5
  li x29, 0x5
  bne x3, x29, fail
  # case 701
  li x28, 701
  li x1, 0x1
  xori x3, x1, 0
  li x29, 0x1
  bne x3, x29, fail
  # case 702
  li x28, 702
  li x1, 0x1
  xori x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 703
  li x28, 703
  li x1, 0x1
  xori x3, x1, -1
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 704
  li x28, 704
  li x1, 0x1
  xori x3, x1, 2047
  li x29, 0x7fe
  bne x3, x29, fail
  # case 705
  li x28, 705
  li x1, 0x1
  xori x3, x1, -2048
  li x29, 0xfffff801
  bne x3, x29, fail
  # case 706
  li x28, 706
  li x1, 0x1
  xori x3, x1, 2032
  li x29, 0x7f1
  bne x3, x29, fail
  # case 707
  li x28, 707
  li x1, 0x1
  xori x3, x1, 31
  li x29, 0x1e
  bne x3, x29, fail
  # case 708
  li x28, 708
  li x1, 0x1
  xori x3, x1, 5
  li x29, 0x4
  bne x3, x29, fail
  # case 709
  li x28, 709
  li x1, 0x2
  xori x3, x1, 0
  li x29, 0x2
  bne x3, x29, fail
  # case 710
  li x28, 710
  li x1, 0x2
  xori x3, x1, 1
  li x29, 0x3
  bne x3, x29, fail
  # case 711
  li x28, 711
  li x1, 0x2
  xori x3, x1, -1
  li x29, 0xfffffffd
  bne x3, x29, fail
  # case 712
  li x28, 712
  li x1, 0x2
  xori x3, x1, 2047
  li x29, 0x7fd
  bne x3, x29, fail
  # case 713
  li x28, 713
  li x1, 0x2
  xori x3, x1, -2048
  li x29, 0xfffff802
  bne x3, x29, fail
  # case 714
  li x28, 714
  li x1, 0x2
  xori x3, x1, 2032
  li x29, 0x7f2
  bne x3, x29, fail
  # case 715
  li x28, 715
  li x1, 0x2
  xori x3, x1, 31
  li x29, 0x1d
  bne x3, x29, fail
  # case 716
  li x28, 716
  li x1, 0x2
  xori x3, x1, 5
  li x29, 0x7
  bne x3, x29, fail
  # case 717
  li x28, 717
  li x1, 0x7fffffff
  xori x3, x1, 0
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 718
  li x28, 718
  li x1, 0x7fffffff
  xori x3, x1, 1
  li x29, 0x7ffffffe
  bne x3, x29, fail
  # case 719
  li x28, 719
  li x1, 0x7fffffff
  xori x3, x1, -1
  li x29, 0x80000000
  bne x3, x29, fail
  # case 720
  li x28, 720
  li x1, 0x7fffffff
  xori x3, x1, 2047
  li x29, 0x7ffff800
  bne x3, x29, fail
  # case 721
  li x28, 721
  li x1, 0x7fffffff
  xori x3, x1, -2048
  li x29, 0x800007ff
  bne x3, x29, fail
  # case 722
  li x28, 722
  li x1, 0x7fffffff
  xori x3, x1, 2032
  li x29, 0x7ffff80f
  bne x3, x29, fail
  # case 723
  li x28, 723
  li x1, 0x7fffffff
  xori x3, x1, 31
  li x29, 0x7fffffe0
  bne x3, x29, fail
  # case 724
  li x28, 724
  li x1, 0x7fffffff
  xori x3, x1, 5
  li x29, 0x7ffffffa
  bne x3, x29, fail
  # case 725
  li x28, 725
  li x1, 0x80000000
  xori x3, x1, 0
  li x29, 0x80000000
  bne x3, x29, fail
  # case 726
  li x28, 726
  li x1, 0x80000000
  xori x3, x1, 1
  li x29, 0x80000001
  bne x3, x29, fail
  # case 727
  li x28, 727
  li x1, 0x80000000
  xori x3, x1, -1
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 728
  li x28, 728
  li x1, 0x80000000
  xori x3, x1, 2047
  li x29, 0x800007ff
  bne x3, x29, fail
  # case 729
  li x28, 729
  li x1, 0x80000000
  xori x3, x1, -2048
  li x29, 0x7ffff800
  bne x3, x29, fail
  # case 730
  li x28, 730
  li x1, 0x80000000
  xori x3, x1, 2032
  li x29, 0x800007f0
  bne x3, x29, fail
  # case 731
  li x28, 731
  li x1, 0x80000000
  xori x3, x1, 31
  li x29, 0x8000001f
  bne x3, x29, fail
  # case 732
  li x28, 732
  li x1, 0x80000000
  xori x3, x1, 5
  li x29, 0x80000005
  bne x3, x29, fail
  # case 733
  li x28, 733
  li x1, 0xffffffff
  xori x3, x1, 0
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 734
  li x28, 734
  li x1, 0xffffffff
  xori x3, x1, 1
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 735
  li x28, 735
  li x1, 0xffffffff
  xori x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 736
  li x28, 736
  li x1, 0xffffffff
  xori x3, x1, 2047
  li x29, 0xfffff800
  bne x3, x29, fail
  # case 737
  li x28, 737
  li x1, 0xffffffff
  xori x3, x1, -2048
  li x29, 0x7ff
  bne x3, x29, fail
  # case 738
  li x28, 738
  li x1, 0xffffffff
  xori x3, x1, 2032
  li x29, 0xfffff80f
  bne x3, x29, fail
  # case 739
  li x28, 739
  li x1, 0xffffffff
  xori x3, x1, 31
  li x29, 0xffffffe0
  bne x3, x29, fail
  # case 740
  li x28, 740
  li x1, 0xffffffff
  xori x3, x1, 5
  li x29, 0xfffffffa
  bne x3, x29, fail
  # case 741
  li x28, 741
  li x1, 0x12345678
  xori x3, x1, 0
  li x29, 0x12345678
  bne x3, x29, fail
  # case 742
  li x28, 742
  li x1, 0x12345678
  xori x3, x1, 1
  li x29, 0x12345679
  bne x3, x29, fail
  # case 743
  li x28, 743
  li x1, 0x12345678
  xori x3, x1, -1
  li x29, 0xedcba987
  bne x3, x29, fail
  # case 744
  li x28, 744
  li x1, 0x12345678
  xori x3, x1, 2047
  li x29, 0x12345187
  bne x3, x29, fail
  # case 745
  li x28, 745
  li x1, 0x12345678
  xori x3, x1, -2048
  li x29, 0xedcbae78
  bne x3, x29, fail
  # case 746
  li x28, 746
  li x1, 0x12345678
  xori x3, x1, 2032
  li x29, 0x12345188
  bne x3, x29, fail
  # case 747
  li x28, 747
  li x1, 0x12345678
  xori x3, x1, 31
  li x29, 0x12345667
  bne x3, x29, fail
  # case 748
  li x28, 748
  li x1, 0x12345678
  xori x3, x1, 5
  li x29, 0x1234567d
  bne x3, x29, fail
  # case 749
  li x28, 749
  li x1, 0xfedcba98
  xori x3, x1, 0
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 750
  li x28, 750
  li x1, 0xfedcba98
  xori x3, x1, 1
  li x29, 0xfedcba99
  bne x3, x29, fail
  # case 751
  li x28, 751
  li x1, 0xfedcba98
  xori x3, x1, -1
  li x29, 0x1234567
  bne x3, x29, fail
  # case 752
  li x28, 752
  li x1, 0xfedcba98
  xori x3, x1, 2047
  li x29, 0xfedcbd67
  bne x3, x29, fail
  # case 753
  li x28, 753
  li x1, 0xfedcba98
  xori x3, x1, -2048
  li x29, 0x1234298
  bne x3, x29, fail
  # case 754
  li x28, 754
  li x1, 0xfedcba98
  xori x3, x1, 2032
  li x29, 0xfedcbd68
  bne x3, x29, fail
  # case 755
  li x28, 755
  li x1, 0xfedcba98
  xori x3, x1, 31
  li x29, 0xfedcba87
  bne x3, x29, fail
  # case 756
  li x28, 756
  li x1, 0xfedcba98
  xori x3, x1, 5
  li x29, 0xfedcba9d
  bne x3, x29, fail
  # case 757
  li x28, 757
  li x1, 0x0
  ori x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 758
  li x28, 758
  li x1, 0x0
  ori x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 759
  li x28, 759
  li x1, 0x0
  ori x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 760
  li x28, 760
  li x1, 0x0
  ori x3, x1, 2047
  li x29, 0x7ff
  bne x3, x29, fail
  # case 761
  li x28, 761
  li x1, 0x0
  ori x3, x1, -2048
  li x29, 0xfffff800
  bne x3, x29, fail
  # case 762
  li x28, 762
  li x1, 0x0
  ori x3, x1, 2032
  li x29, 0x7f0
  bne x3, x29, fail
  # case 763
  li x28, 763
  li x1, 0x0
  ori x3, x1, 31
  li x29, 0x1f
  bne x3, x29, fail
  # case 764
  li x28, 764
  li x1, 0x0
  ori x3, x1, 5
  li x29, 0x5
  bne x3, x29, fail
  # case 765
  li x28, 765
  li x1, 0x1
  ori x3, x1, 0
  li x29, 0x1
  bne x3, x29, fail
  # case 766
  li x28, 766
  li x1, 0x1
  ori x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 767
  li x28, 767
  li x1, 0x1
  ori x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 768
  li x28, 768
  li x1, 0x1
  ori x3, x1, 2047
  li x29, 0x7ff
  bne x3, x29, fail
  # case 769
  li x28, 769
  li x1, 0x1
  ori x3, x1, -2048
  li x29, 0xfffff801
  bne x3, x29, fail
  # case 770
  li x28, 770
  li x1, 0x1
  ori x3, x1, 2032
  li x29, 0x7f1
  bne x3, x29, fail
  # case 771
  li x28, 771
  li x1, 0x1
  ori x3, x1, 31
  li x29, 0x1f
  bne x3, x29, fail
  # case 772
  li x28, 772
  li x1, 0x1
  ori x3, x1, 5
  li x29, 0x5
  bne x3, x29, fail
  # case 773
  li x28, 773
  li x1, 0x2
  ori x3, x1, 0
  li x29, 0x2
  bne x3, x29, fail
  # case 774
  li x28, 774
  li x1, 0x2
  ori x3, x1, 1
  li x29, 0x3
  bne x3, x29, fail
  # case 775
  li x28, 775
  li x1, 0x2
  ori x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 776
  li x28, 776
  li x1, 0x2
  ori x3, x1, 2047
  li x29, 0x7ff
  bne x3, x29, fail
  # case 777
  li x28, 777
  li x1, 0x2
  ori x3, x1, -2048
  li x29, 0xfffff802
  bne x3, x29, fail
  # case 778
  li x28, 778
  li x1, 0x2
  ori x3, x1, 2032
  li x29, 0x7f2
  bne x3, x29, fail
  # case 779
  li x28, 779
  li x1, 0x2
  ori x3, x1, 31
  li x29, 0x1f
  bne x3, x29, fail
  # case 780
  li x28, 780
  li x1, 0x2
  ori x3, x1, 5
  li x29, 0x7
  bne x3, x29, fail
  # case 781
  li x28, 781
  li x1, 0x7fffffff
  ori x3, x1, 0
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 782
  li x28, 782
  li x1, 0x7fffffff
  ori x3, x1, 1
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 783
  li x28, 783
  li x1, 0x7fffffff
  ori x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 784
  li x28, 784
  li x1, 0x7fffffff
  ori x3, x1, 2047
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 785
  li x28, 785
  li x1, 0x7fffffff
  ori x3, x1, -2048
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 786
  li x28, 786
  li x1, 0x7fffffff
  ori x3, x1, 2032
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 787
  li x28, 787
  li x1, 0x7fffffff
  ori x3, x1, 31
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 788
  li x28, 788
  li x1, 0x7fffffff
  ori x3, x1, 5
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 789
  li x28, 789
  li x1, 0x80000000
  ori x3, x1, 0
  li x29, 0x80000000
  bne x3, x29, fail
  # case 790
  li x28, 790
  li x1, 0x80000000
  ori x3, x1, 1
  li x29, 0x80000001
  bne x3, x29, fail
  # case 791
  li x28, 791
  li x1, 0x80000000
  ori x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 792
  li x28, 792
  li x1, 0x80000000
  ori x3, x1, 2047
  li x29, 0x800007ff
  bne x3, x29, fail
  # case 793
  li x28, 793
  li x1, 0x80000000
  ori x3, x1, -2048
  li x29, 0xfffff800
  bne x3, x29, fail
  # case 794
  li x28, 794
  li x1, 0x80000000
  ori x3, x1, 2032
  li x29, 0x800007f0
  bne x3, x29, fail
  # case 795
  li x28, 795
  li x1, 0x80000000
  ori x3, x1, 31
  li x29, 0x8000001f
  bne x3, x29, fail
  # case 796
  li x28, 796
  li x1, 0x80000000
  ori x3, x1, 5
  li x29, 0x80000005
  bne x3, x29, fail
  # case 797
  li x28, 797
  li x1, 0xffffffff
  ori x3, x1, 0
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 798
  li x28, 798
  li x1, 0xffffffff
  ori x3, x1, 1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 799
  li x28, 799
  li x1, 0xffffffff
  ori x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 800
  li x28, 800
  li x1, 0xffffffff
  ori x3, x1, 2047
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 801
  li x28, 801
  li x1, 0xffffffff
  ori x3, x1, -2048
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 802
  li x28, 802
  li x1, 0xffffffff
  ori x3, x1, 2032
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 803
  li x28, 803
  li x1, 0xffffffff
  ori x3, x1, 31
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 804
  li x28, 804
  li x1, 0xffffffff
  ori x3, x1, 5
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 805
  li x28, 805
  li x1, 0x12345678
  ori x3, x1, 0
  li x29, 0x12345678
  bne x3, x29, fail
  # case 806
  li x28, 806
  li x1, 0x12345678
  ori x3, x1, 1
  li x29, 0x12345679
  bne x3, x29, fail
  # case 807
  li x28, 807
  li x1, 0x12345678
  ori x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 808
  li x28, 808
  li x1, 0x12345678
  ori x3, x1, 2047
  li x29, 0x123457ff
  bne x3, x29, fail
  # case 809
  li x28, 809
  li x1, 0x12345678
  ori x3, x1, -2048
  li x29, 0xfffffe78
  bne x3, x29, fail
  # case 810
  li x28, 810
  li x1, 0x12345678
  ori x3, x1, 2032
  li x29, 0x123457f8
  bne x3, x29, fail
  # case 811
  li x28, 811
  li x1, 0x12345678
  ori x3, x1, 31
  li x29, 0x1234567f
  bne x3, x29, fail
  # case 812
  li x28, 812
  li x1, 0x12345678
  ori x3, x1, 5
  li x29, 0x1234567d
  bne x3, x29, fail
  # case 813
  li x28, 813
  li x1, 0xfedcba98
  ori x3, x1, 0
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 814
  li x28, 814
  li x1, 0xfedcba98
  ori x3, x1, 1
  li x29, 0xfedcba99
  bne x3, x29, fail
  # case 815
  li x28, 815
  li x1, 0xfedcba98
  ori x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 816
  li x28, 816
  li x1, 0xfedcba98
  ori x3, x1, 2047
  li x29, 0xfedcbfff
  bne x3, x29, fail
  # case 817
  li x28, 817
  li x1, 0xfedcba98
  ori x3, x1, -2048
  li x29, 0xfffffa98
  bne x3, x29, fail
  # case 818
  li x28, 818
  li x1, 0xfedcba98
  ori x3, x1, 2032
  li x29, 0xfedcbff8
  bne x3, x29, fail
  # case 819
  li x28, 819
  li x1, 0xfedcba98
  ori x3, x1, 31
  li x29, 0xfedcba9f
  bne x3, x29, fail
  # case 820
  li x28, 820
  li x1, 0xfedcba98
  ori x3, x1, 5
  li x29, 0xfedcba9d
  bne x3, x29, fail
  # case 821
  li x28, 821
  li x1, 0x0
  andi x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 822
  li x28, 822
  li x1, 0x0
  andi x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 823
  li x28, 823
  li x1, 0x0
  andi x3, x1, -1
  li x29, 0x0
  bne x3, x29, fail
  # case 824
  li x28, 824
  li x1, 0x0
  andi x3, x1, 2047
  li x29, 0x0
  bne x3, x29, fail
  # case 825
  li x28, 825
  li x1, 0x0
  andi x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 826
  li x28, 826
  li x1, 0x0
  andi x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 827
  li x28, 827
  li x1, 0x0
  andi x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 828
  li x28, 828
  li x1, 0x0
  andi x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 829
  li x28, 829
  li x1, 0x1
  andi x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 830
  li x28, 830
  li x1, 0x1
  andi x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 831
  li x28, 831
  li x1, 0x1
  andi x3, x1, -1
  li x29, 0x1
  bne x3, x29, fail
  # case 832
  li x28, 832
  li x1, 0x1
  andi x3, x1, 2047
  li x29, 0x1
  bne x3, x29, fail
  # case 833
  li x28, 833
  li x1, 0x1
  andi x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 834
  li x28, 834
  li x1, 0x1
  andi x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 835
  li x28, 835
  li x1, 0x1
  andi x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 836
  li x28, 836
  li x1, 0x1
  andi x3, x1, 5
  li x29, 0x1
  bne x3, x29, fail
  # case 837
  li x28, 837
  li x1, 0x2
  andi x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 838
  li x28, 838
  li x1, 0x2
  andi x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 839
  li x28, 839
  li x1, 0x2
  andi x3, x1, -1
  li x29, 0x2
  bne x3, x29, fail
  # case 840
  li x28, 840
  li x1, 0x2
  andi x3, x1, 2047
  li x29, 0x2
  bne x3, x29, fail
  # case 841
  li x28, 841
  li x1, 0x2
  andi x3, x1, -2048
  li x29, 0x0
  bne x3, x29, fail
  # case 842
  li x28, 842
  li x1, 0x2
  andi x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 843
  li x28, 843
  li x1, 0x2
  andi x3, x1, 31
  li x29, 0x2
  bne x3, x29, fail
  # case 844
  li x28, 844
  li x1, 0x2
  andi x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 845
  li x28, 845
  li x1, 0x7fffffff
  andi x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 846
  li x28, 846
  li x1, 0x7fffffff
  andi x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 847
  li x28, 847
  li x1, 0x7fffffff
  andi x3, x1, -1
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 848
  li x28, 848
  li x1, 0x7fffffff
  andi x3, x1, 2047
  li x29, 0x7ff
  bne x3, x29, fail
  # case 849
  li x28, 849
  li x1, 0x7fffffff
  andi x3, x1, -2048
  li x29, 0x7ffff800
  bne x3, x29, fail
  # case 850
  li x28, 850
  li x1, 0x7fffffff
  andi x3, x1, 2032
  li x29, 0x7f0
  bne x3, x29, fail
  # case 851
  li x28, 851
  li x1, 0x7fffffff
  andi x3, x1, 31
  li x29, 0x1f
  bne x3, x29, fail
  # case 852
  li x28, 852
  li x1, 0x7fffffff
  andi x3, x1, 5
  li x29, 0x5
  bne x3, x29, fail
  # case 853
  li x28, 853
  li x1, 0x80000000
  andi x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 854
  li x28, 854
  li x1, 0x80000000
  andi x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 855
  li x28, 855
  li x1, 0x80000000
  andi x3, x1, -1
  li x29, 0x80000000
  bne x3, x29, fail
  # case 856
  li x28, 856
  li x1, 0x80000000
  andi x3, x1, 2047
  li x29, 0x0
  bne x3, x29, fail
  # case 857
  li x28, 857
  li x1, 0x80000000
  andi x3, x1, -2048
  li x29, 0x80000000
  bne x3, x29, fail
  # case 858
  li x28, 858
  li x1, 0x80000000
  andi x3, x1, 2032
  li x29, 0x0
  bne x3, x29, fail
  # case 859
  li x28, 859
  li x1, 0x80000000
  andi x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 860
  li x28, 860
  li x1, 0x80000000
  andi x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 861
  li x28, 861
  li x1, 0xffffffff
  andi x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 862
  li x28, 862
  li x1, 0xffffffff
  andi x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 863
  li x28, 863
  li x1, 0xffffffff
  andi x3, x1, -1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 864
  li x28, 864
  li x1, 0xffffffff
  andi x3, x1, 2047
  li x29, 0x7ff
  bne x3, x29, fail
  # case 865
  li x28, 865
  li x1, 0xffffffff
  andi x3, x1, -2048
  li x29, 0xfffff800
  bne x3, x29, fail
  # case 866
  li x28, 866
  li x1, 0xffffffff
  andi x3, x1, 2032
  li x29, 0x7f0
  bne x3, x29, fail
  # case 867
  li x28, 867
  li x1, 0xffffffff
  andi x3, x1, 31
  li x29, 0x1f
  bne x3, x29, fail
  # case 868
  li x28, 868
  li x1, 0xffffffff
  andi x3, x1, 5
  li x29, 0x5
  bne x3, x29, fail
  # case 869
  li x28, 869
  li x1, 0x12345678
  andi x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 870
  li x28, 870
  li x1, 0x12345678
  andi x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 871
  li x28, 871
  li x1, 0x12345678
  andi x3, x1, -1
  li x29, 0x12345678
  bne x3, x29, fail
  # case 872
  li x28, 872
  li x1, 0x12345678
  andi x3, x1, 2047
  li x29, 0x678
  bne x3, x29, fail
  # case 873
  li x28, 873
  li x1, 0x12345678
  andi x3, x1, -2048
  li x29, 0x12345000
  bne x3, x29, fail
  # case 874
  li x28, 874
  li x1, 0x12345678
  andi x3, x1, 2032
  li x29, 0x670
  bne x3, x29, fail
  # case 875
  li x28, 875
  li x1, 0x12345678
  andi x3, x1, 31
  li x29, 0x18
  bne x3, x29, fail
  # case 876
  li x28, 876
  li x1, 0x12345678
  andi x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 877
  li x28, 877
  li x1, 0xfedcba98
  andi x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 878
  li x28, 878
  li x1, 0xfedcba98
  andi x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 879
  li x28, 879
  li x1, 0xfedcba98
  andi x3, x1, -1
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 880
  li x28, 880
  li x1, 0xfedcba98
  andi x3, x1, 2047
  li x29, 0x298
  bne x3, x29, fail
  # case 881
  li x28, 881
  li x1, 0xfedcba98
  andi x3, x1, -2048
  li x29, 0xfedcb800
  bne x3, x29, fail
  # case 882
  li x28, 882
  li x1, 0xfedcba98
  andi x3, x1, 2032
  li x29, 0x290
  bne x3, x29, fail
  # case 883
  li x28, 883
  li x1, 0xfedcba98
  andi x3, x1, 31
  li x29, 0x18
  bne x3, x29, fail
  # case 884
  li x28, 884
  li x1, 0xfedcba98
  andi x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 885
  li x28, 885
  li x1, 0x0
  slli x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 886
  li x28, 886
  li x1, 0x0
  slli x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 887
  li x28, 887
  li x1, 0x0
  slli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 888
  li x28, 888
  li x1, 0x0
  slli x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 889
  li x28, 889
  li x1, 0x1
  slli x3, x1, 0
  li x29, 0x1
  bne x3, x29, fail
  # case 890
  li x28, 890
  li x1, 0x1
  slli x3, x1, 1
  li x29, 0x2
  bne x3, x29, fail
  # case 891
  li x28, 891
  li x1, 0x1
  slli x3, x1, 31
  li x29, 0x80000000
  bne x3, x29, fail
  # case 892
  li x28, 892
  li x1, 0x1
  slli x3, x1, 5
  li x29, 0x20
  bne x3, x29, fail
  # case 893
  li x28, 893
  li x1, 0x2
  slli x3, x1, 0
  li x29, 0x2
  bne x3, x29, fail
  # case 894
  li x28, 894
  li x1, 0x2
  slli x3, x1, 1
  li x29, 0x4
  bne x3, x29, fail
  # case 895
  li x28, 895
  li x1, 0x2
  slli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 896
  li x28, 896
  li x1, 0x2
  slli x3, x1, 5
  li x29, 0x40
  bne x3, x29, fail
  # case 897
  li x28, 897
  li x1, 0x7fffffff
  slli x3, x1, 0
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 898
  li x28, 898
  li x1, 0x7fffffff
  slli x3, x1, 1
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 899
  li x28, 899
  li x1, 0x7fffffff
  slli x3, x1, 31
  li x29, 0x80000000
  bne x3, x29, fail
  # case 900
  li x28, 900
  li x1, 0x7fffffff
  slli x3, x1, 5
  li x29, 0xffffffe0
  bne x3, x29, fail
  # case 901
  li x28, 901
  li x1, 0x80000000
  slli x3, x1, 0
  li x29, 0x80000000
  bne x3, x29, fail
  # case 902
  li x28, 902
  li x1, 0x80000000
  slli x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 903
  li x28, 903
  li x1, 0x80000000
  slli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 904
  li x28, 904
  li x1, 0x80000000
  slli x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 905
  li x28, 905
  li x1, 0xffffffff
  slli x3, x1, 0
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 906
  li x28, 906
  li x1, 0xffffffff
  slli x3, x1, 1
  li x29, 0xfffffffe
  bne x3, x29, fail
  # case 907
  li x28, 907
  li x1, 0xffffffff
  slli x3, x1, 31
  li x29, 0x80000000
  bne x3, x29, fail
  # case 908
  li x28, 908
  li x1, 0xffffffff
  slli x3, x1, 5
  li x29, 0xffffffe0
  bne x3, x29, fail
  # case 909
  li x28, 909
  li x1, 0x12345678
  slli x3, x1, 0
  li x29, 0x12345678
  bne x3, x29, fail
  # case 910
  li x28, 910
  li x1, 0x12345678
  slli x3, x1, 1
  li x29, 0x2468acf0
  bne x3, x29, fail
  # case 911
  li x28, 911
  li x1, 0x12345678
  slli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 912
  li x28, 912
  li x1, 0x12345678
  slli x3, x1, 5
  li x29, 0x468acf00
  bne x3, x29, fail
  # case 913
  li x28, 913
  li x1, 0xfedcba98
  slli x3, x1, 0
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 914
  li x28, 914
  li x1, 0xfedcba98
  slli x3, x1, 1
  li x29, 0xfdb97530
  bne x3, x29, fail
  # case 915
  li x28, 915
  li x1, 0xfedcba98
  slli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 916
  li x28, 916
  li x1, 0xfedcba98
  slli x3, x1, 5
  li x29, 0xdb975300
  bne x3, x29, fail
  # case 917
  li x28, 917
  li x1, 0x0
  srli x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 918
  li x28, 918
  li x1, 0x0
  srli x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 919
  li x28, 919
  li x1, 0x0
  srli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 920
  li x28, 920
  li x1, 0x0
  srli x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 921
  li x28, 921
  li x1, 0x1
  srli x3, x1, 0
  li x29, 0x1
  bne x3, x29, fail
  # case 922
  li x28, 922
  li x1, 0x1
  srli x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 923
  li x28, 923
  li x1, 0x1
  srli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 924
  li x28, 924
  li x1, 0x1
  srli x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 925
  li x28, 925
  li x1, 0x2
  srli x3, x1, 0
  li x29, 0x2
  bne x3, x29, fail
  # case 926
  li x28, 926
  li x1, 0x2
  srli x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 927
  li x28, 927
  li x1, 0x2
  srli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 928
  li x28, 928
  li x1, 0x2
  srli x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 929
  li x28, 929
  li x1, 0x7fffffff
  srli x3, x1, 0
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 930
  li x28, 930
  li x1, 0x7fffffff
  srli x3, x1, 1
  li x29, 0x3fffffff
  bne x3, x29, fail
  # case 931
  li x28, 931
  li x1, 0x7fffffff
  srli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 932
  li x28, 932
  li x1, 0x7fffffff
  srli x3, x1, 5
  li x29, 0x3ffffff
  bne x3, x29, fail
  # case 933
  li x28, 933
  li x1, 0x80000000
  srli x3, x1, 0
  li x29, 0x80000000
  bne x3, x29, fail
  # case 934
  li x28, 934
  li x1, 0x80000000
  srli x3, x1, 1
  li x29, 0x40000000
  bne x3, x29, fail
  # case 935
  li x28, 935
  li x1, 0x80000000
  srli x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 936
  li x28, 936
  li x1, 0x80000000
  srli x3, x1, 5
  li x29, 0x4000000
  bne x3, x29, fail
  # case 937
  li x28, 937
  li x1, 0xffffffff
  srli x3, x1, 0
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 938
  li x28, 938
  li x1, 0xffffffff
  srli x3, x1, 1
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 939
  li x28, 939
  li x1, 0xffffffff
  srli x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 940
  li x28, 940
  li x1, 0xffffffff
  srli x3, x1, 5
  li x29, 0x7ffffff
  bne x3, x29, fail
  # case 941
  li x28, 941
  li x1, 0x12345678
  srli x3, x1, 0
  li x29, 0x12345678
  bne x3, x29, fail
  # case 942
  li x28, 942
  li x1, 0x12345678
  srli x3, x1, 1
  li x29, 0x91a2b3c
  bne x3, x29, fail
  # case 943
  li x28, 943
  li x1, 0x12345678
  srli x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 944
  li x28, 944
  li x1, 0x12345678
  srli x3, x1, 5
  li x29, 0x91a2b3
  bne x3, x29, fail
  # case 945
  li x28, 945
  li x1, 0xfedcba98
  srli x3, x1, 0
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 946
  li x28, 946
  li x1, 0xfedcba98
  srli x3, x1, 1
  li x29, 0x7f6e5d4c
  bne x3, x29, fail
  # case 947
  li x28, 947
  li x1, 0xfedcba98
  srli x3, x1, 31
  li x29, 0x1
  bne x3, x29, fail
  # case 948
  li x28, 948
  li x1, 0xfedcba98
  srli x3, x1, 5
  li x29, 0x7f6e5d4
  bne x3, x29, fail
  # case 949
  li x28, 949
  li x1, 0x0
  srai x3, x1, 0
  li x29, 0x0
  bne x3, x29, fail
  # case 950
  li x28, 950
  li x1, 0x0
  srai x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 951
  li x28, 951
  li x1, 0x0
  srai x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 952
  li x28, 952
  li x1, 0x0
  srai x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 953
  li x28, 953
  li x1, 0x1
  srai x3, x1, 0
  li x29, 0x1
  bne x3, x29, fail
  # case 954
  li x28, 954
  li x1, 0x1
  srai x3, x1, 1
  li x29, 0x0
  bne x3, x29, fail
  # case 955
  li x28, 955
  li x1, 0x1
  srai x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 956
  li x28, 956
  li x1, 0x1
  srai x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 957
  li x28, 957
  li x1, 0x2
  srai x3, x1, 0
  li x29, 0x2
  bne x3, x29, fail
  # case 958
  li x28, 958
  li x1, 0x2
  srai x3, x1, 1
  li x29, 0x1
  bne x3, x29, fail
  # case 959
  li x28, 959
  li x1, 0x2
  srai x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 960
  li x28, 960
  li x1, 0x2
  srai x3, x1, 5
  li x29, 0x0
  bne x3, x29, fail
  # case 961
  li x28, 961
  li x1, 0x7fffffff
  srai x3, x1, 0
  li x29, 0x7fffffff
  bne x3, x29, fail
  # case 962
  li x28, 962
  li x1, 0x7fffffff
  srai x3, x1, 1
  li x29, 0x3fffffff
  bne x3, x29, fail
  # case 963
  li x28, 963
  li x1, 0x7fffffff
  srai x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 964
  li x28, 964
  li x1, 0x7fffffff
  srai x3, x1, 5
  li x29, 0x3ffffff
  bne x3, x29, fail
  # case 965
  li x28, 965
  li x1, 0x80000000
  srai x3, x1, 0
  li x29, 0x80000000
  bne x3, x29, fail
  # case 966
  li x28, 966
  li x1, 0x80000000
  srai x3, x1, 1
  li x29, 0xc0000000
  bne x3, x29, fail
  # case 967
  li x28, 967
  li x1, 0x80000000
  srai x3, x1, 31
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 968
  li x28, 968
  li x1, 0x80000000
  srai x3, x1, 5
  li x29, 0xfc000000
  bne x3, x29, fail
  # case 969
  li x28, 969
  li x1, 0xffffffff
  srai x3, x1, 0
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 970
  li x28, 970
  li x1, 0xffffffff
  srai x3, x1, 1
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 971
  li x28, 971
  li x1, 0xffffffff
  srai x3, x1, 31
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 972
  li x28, 972
  li x1, 0xffffffff
  srai x3, x1, 5
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 973
  li x28, 973
  li x1, 0x12345678
  srai x3, x1, 0
  li x29, 0x12345678
  bne x3, x29, fail
  # case 974
  li x28, 974
  li x1, 0x12345678
  srai x3, x1, 1
  li x29, 0x91a2b3c
  bne x3, x29, fail
  # case 975
  li x28, 975
  li x1, 0x12345678
  srai x3, x1, 31
  li x29, 0x0
  bne x3, x29, fail
  # case 976
  li x28, 976
  li x1, 0x12345678
  srai x3, x1, 5
  li x29, 0x91a2b3
  bne x3, x29, fail
  # case 977
  li x28, 977
  li x1, 0xfedcba98
  srai x3, x1, 0
  li x29, 0xfedcba98
  bne x3, x29, fail
  # case 978
  li x28, 978
  li x1, 0xfedcba98
  srai x3, x1, 1
  li x29, 0xff6e5d4c
  bne x3, x29, fail
  # case 979
  li x28, 979
  li x1, 0xfedcba98
  srai x3, x1, 31
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 980
  li x28, 980
  li x1, 0xfedcba98
  srai x3, x1, 5
  li x29, 0xfff6e5d4
  bne x3, x29, fail
  # case 981
  li x28, 981
  lui x3, 0x0
  li x29, 0x0
  bne x3, x29, fail
  # case 982
  li x28, 982
  lui x3, 0x1
  li x29, 0x1000
  bne x3, x29, fail
  # case 983
  li x28, 983
  lui x3, 0x80000
  li x29, 0x80000000
  bne x3, x29, fail
  # case 984
  li x28, 984
  lui x3, 0xfffff
  li x29, 0xfffff000
  bne x3, x29, fail
  # case 985
  li x28, 985
  lui x3, 0x12345
  li x29, 0x12345000
  bne x3, x29, fail
  # case 986
  li x28, 986
  auipc x3, 0
  auipc x4, 0
  sub x3, x4, x3
  li x29, 0x4
  bne x3, x29, fail
  # case 987
  li x28, 987
  auipc x3, 1
  auipc x4, 0
  sub x3, x3, x4
  li x29, 0xffc
  bne x3, x29, fail
  la x10, tdata
  # case 988
  li x28, 988
  lw x3, 0(x10)
  li x29, 0xff00ff
  bne x3, x29, fail
  # case 989
  li x28, 989
  lw x3, 4(x10)
  li x29, 0xff00ff00
  bne x3, x29, fail
  # case 990
  li x28, 990
  lw x3, 8(x10)
  li x29, 0xff00ff0
  bne x3, x29, fail
  # case 991
  li x28, 991
  lw x3, 12(x10)
  li x29, 0xf00ff00f
  bne x3, x29, fail
  # case 992
  li x28, 992
  lb x3, 0(x10)
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 993
  li x28, 993
  lbu x3, 0(x10)
  li x29, 0xff
  bne x3, x29, fail
  # case 994
  li x28, 994
  lb x3, 1(x10)
  li x29, 0x0
  bne x3, x29, fail
  # case 995
  li x28, 995
  lbu x3, 1(x10)
  li x29, 0x0
  bne x3, x29, fail
  # case 996
  li x28, 996
  lb x3, 2(x10)
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 997
  li x28, 997
  lbu x3, 2(x10)
  li x29, 0xff
  bne x3, x29, fail
  # case 998
  li x28, 998
  lb x3, 3(x10)
  li x29, 0x0
  bne x3, x29, fail
  # case 999
  li x28, 999
  lbu x3, 3(x10)
  li x29, 0x0
  bne x3, x29, fail
  # case 1000
  li x28, 1000
  lh x3, 0(x10)
  li x29, 0xff
  bne x3, x29, fail
  # case 1001
  li x28, 1001
  lh x3, 2(x10)
  li x29, 0xff
  bne x3, x29, fail
  # case 1002
  li x28, 1002
  lh x3, 4(x10)
  li x29, 0xffffff00
  bne x3, x29, fail
  # case 1003
  li x28, 1003
  lhu x3, 6(x10)
  li x29, 0xff00
  bne x3, x29, fail
  # case 1004
  li x28, 1004
  lh x3, 6(x10)
  li x29, 0xffffff00
  bne x3, x29, fail
  la x11, sbuf
  # case 1005
  li x28, 1005
  li x1, 0xAABBCCDD
  sw x1, 0(x11)
  lw x3, 0(x11)
  li x29, 0xaabbccdd
  bne x3, x29, fail
  # case 1006
  li x28, 1006
  li x1, 0x11
  sb x1, 1(x11)
  lw x3, 0(x11)
  li x29, 0xaabb11dd
  bne x3, x29, fail
  # case 1007
  li x28, 1007
  li x1, 0x2233
  sh x1, 2(x11)
  lw x3, 0(x11)
  li x29, 0x223311dd
  bne x3, x29, fail
  # case 1008
  li x28, 1008
  li x1, -1
  sw x1, -4(x11)
  lw x3, -4(x11)
  li x29, 0xffffffff
  bne x3, x29, fail
  # case 1009
  li x28, 1009
  li x1, 0x80
  sb x1, 0(x11)
  lb x3, 0(x11)
  li x29, 0xffffff80
  bne x3, x29, fail
  # case 1010
  li x28, 1010
  li x1, 0x0
  li x2, 0x0
  li x3, 0
  beq x1, x2, L1010t
  li x3, 2
  j L1010e
  L1010t: li x3, 1
  L1010e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1011
  li x28, 1011
  li x1, 0x1
  li x2, 0x0
  li x3, 0
  beq x1, x2, L1011t
  li x3, 2
  j L1011e
  L1011t: li x3, 1
  L1011e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1012
  li x28, 1012
  li x1, 0x0
  li x2, 0x1
  li x3, 0
  beq x1, x2, L1012t
  li x3, 2
  j L1012e
  L1012t: li x3, 1
  L1012e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1013
  li x28, 1013
  li x1, 0x80000000
  li x2, 0x1
  li x3, 0
  beq x1, x2, L1013t
  li x3, 2
  j L1013e
  L1013t: li x3, 1
  L1013e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1014
  li x28, 1014
  li x1, 0x1
  li x2, 0x80000000
  li x3, 0
  beq x1, x2, L1014t
  li x3, 2
  j L1014e
  L1014t: li x3, 1
  L1014e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1015
  li x28, 1015
  li x1, 0xffffffff
  li x2, 0x0
  li x3, 0
  beq x1, x2, L1015t
  li x3, 2
  j L1015e
  L1015t: li x3, 1
  L1015e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1016
  li x28, 1016
  li x1, 0x0
  li x2, 0xffffffff
  li x3, 0
  beq x1, x2, L1016t
  li x3, 2
  j L1016e
  L1016t: li x3, 1
  L1016e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1017
  li x28, 1017
  li x1, 0x5
  li x2, 0x5
  li x3, 0
  beq x1, x2, L1017t
  li x3, 2
  j L1017e
  L1017t: li x3, 1
  L1017e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1018
  li x28, 1018
  li x1, 0x0
  li x2, 0x0
  li x3, 0
  bne x1, x2, L1018t
  li x3, 2
  j L1018e
  L1018t: li x3, 1
  L1018e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1019
  li x28, 1019
  li x1, 0x1
  li x2, 0x0
  li x3, 0
  bne x1, x2, L1019t
  li x3, 2
  j L1019e
  L1019t: li x3, 1
  L1019e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1020
  li x28, 1020
  li x1, 0x0
  li x2, 0x1
  li x3, 0
  bne x1, x2, L1020t
  li x3, 2
  j L1020e
  L1020t: li x3, 1
  L1020e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1021
  li x28, 1021
  li x1, 0x80000000
  li x2, 0x1
  li x3, 0
  bne x1, x2, L1021t
  li x3, 2
  j L1021e
  L1021t: li x3, 1
  L1021e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1022
  li x28, 1022
  li x1, 0x1
  li x2, 0x80000000
  li x3, 0
  bne x1, x2, L1022t
  li x3, 2
  j L1022e
  L1022t: li x3, 1
  L1022e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1023
  li x28, 1023
  li x1, 0xffffffff
  li x2, 0x0
  li x3, 0
  bne x1, x2, L1023t
  li x3, 2
  j L1023e
  L1023t: li x3, 1
  L1023e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1024
  li x28, 1024
  li x1, 0x0
  li x2, 0xffffffff
  li x3, 0
  bne x1, x2, L1024t
  li x3, 2
  j L1024e
  L1024t: li x3, 1
  L1024e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1025
  li x28, 1025
  li x1, 0x5
  li x2, 0x5
  li x3, 0
  bne x1, x2, L1025t
  li x3, 2
  j L1025e
  L1025t: li x3, 1
  L1025e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1026
  li x28, 1026
  li x1, 0x0
  li x2, 0x0
  li x3, 0
  blt x1, x2, L1026t
  li x3, 2
  j L1026e
  L1026t: li x3, 1
  L1026e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1027
  li x28, 1027
  li x1, 0x1
  li x2, 0x0
  li x3, 0
  blt x1, x2, L1027t
  li x3, 2
  j L1027e
  L1027t: li x3, 1
  L1027e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1028
  li x28, 1028
  li x1, 0x0
  li x2, 0x1
  li x3, 0
  blt x1, x2, L1028t
  li x3, 2
  j L1028e
  L1028t: li x3, 1
  L1028e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1029
  li x28, 1029
  li x1, 0x80000000
  li x2, 0x1
  li x3, 0
  blt x1, x2, L1029t
  li x3, 2
  j L1029e
  L1029t: li x3, 1
  L1029e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1030
  li x28, 1030
  li x1, 0x1
  li x2, 0x80000000
  li x3, 0
  blt x1, x2, L1030t
  li x3, 2
  j L1030e
  L1030t: li x3, 1
  L1030e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1031
  li x28, 1031
  li x1, 0xffffffff
  li x2, 0x0
  li x3, 0
  blt x1, x2, L1031t
  li x3, 2
  j L1031e
  L1031t: li x3, 1
  L1031e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1032
  li x28, 1032
  li x1, 0x0
  li x2, 0xffffffff
  li x3, 0
  blt x1, x2, L1032t
  li x3, 2
  j L1032e
  L1032t: li x3, 1
  L1032e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1033
  li x28, 1033
  li x1, 0x5
  li x2, 0x5
  li x3, 0
  blt x1, x2, L1033t
  li x3, 2
  j L1033e
  L1033t: li x3, 1
  L1033e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1034
  li x28, 1034
  li x1, 0x0
  li x2, 0x0
  li x3, 0
  bge x1, x2, L1034t
  li x3, 2
  j L1034e
  L1034t: li x3, 1
  L1034e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1035
  li x28, 1035
  li x1, 0x1
  li x2, 0x0
  li x3, 0
  bge x1, x2, L1035t
  li x3, 2
  j L1035e
  L1035t: li x3, 1
  L1035e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1036
  li x28, 1036
  li x1, 0x0
  li x2, 0x1
  li x3, 0
  bge x1, x2, L1036t
  li x3, 2
  j L1036e
  L1036t: li x3, 1
  L1036e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1037
  li x28, 1037
  li x1, 0x80000000
  li x2, 0x1
  li x3, 0
  bge x1, x2, L1037t
  li x3, 2
  j L1037e
  L1037t: li x3, 1
  L1037e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1038
  li x28, 1038
  li x1, 0x1
  li x2, 0x80000000
  li x3, 0
  bge x1, x2, L1038t
  li x3, 2
  j L1038e
  L1038t: li x3, 1
  L1038e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1039
  li x28, 1039
  li x1, 0xffffffff
  li x2, 0x0
  li x3, 0
  bge x1, x2, L1039t
  li x3, 2
  j L1039e
  L1039t: li x3, 1
  L1039e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1040
  li x28, 1040
  li x1, 0x0
  li x2, 0xffffffff
  li x3, 0
  bge x1, x2, L1040t
  li x3, 2
  j L1040e
  L1040t: li x3, 1
  L1040e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1041
  li x28, 1041
  li x1, 0x5
  li x2, 0x5
  li x3, 0
  bge x1, x2, L1041t
  li x3, 2
  j L1041e
  L1041t: li x3, 1
  L1041e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1042
  li x28, 1042
  li x1, 0x0
  li x2, 0x0
  li x3, 0
  bltu x1, x2, L1042t
  li x3, 2
  j L1042e
  L1042t: li x3, 1
  L1042e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1043
  li x28, 1043
  li x1, 0x1
  li x2, 0x0
  li x3, 0
  bltu x1, x2, L1043t
  li x3, 2
  j L1043e
  L1043t: li x3, 1
  L1043e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1044
  li x28, 1044
  li x1, 0x0
  li x2, 0x1
  li x3, 0
  bltu x1, x2, L1044t
  li x3, 2
  j L1044e
  L1044t: li x3, 1
  L1044e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1045
  li x28, 1045
  li x1, 0x80000000
  li x2, 0x1
  li x3, 0
  bltu x1, x2, L1045t
  li x3, 2
  j L1045e
  L1045t: li x3, 1
  L1045e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1046
  li x28, 1046
  li x1, 0x1
  li x2, 0x80000000
  li x3, 0
  bltu x1, x2, L1046t
  li x3, 2
  j L1046e
  L1046t: li x3, 1
  L1046e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1047
  li x28, 1047
  li x1, 0xffffffff
  li x2, 0x0
  li x3, 0
  bltu x1, x2, L1047t
  li x3, 2
  j L1047e
  L1047t: li x3, 1
  L1047e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1048
  li x28, 1048
  li x1, 0x0
  li x2, 0xffffffff
  li x3, 0
  bltu x1, x2, L1048t
  li x3, 2
  j L1048e
  L1048t: li x3, 1
  L1048e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1049
  li x28, 1049
  li x1, 0x5
  li x2, 0x5
  li x3, 0
  bltu x1, x2, L1049t
  li x3, 2
  j L1049e
  L1049t: li x3, 1
  L1049e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1050
  li x28, 1050
  li x1, 0x0
  li x2, 0x0
  li x3, 0
  bgeu x1, x2, L1050t
  li x3, 2
  j L1050e
  L1050t: li x3, 1
  L1050e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1051
  li x28, 1051
  li x1, 0x1
  li x2, 0x0
  li x3, 0
  bgeu x1, x2, L1051t
  li x3, 2
  j L1051e
  L1051t: li x3, 1
  L1051e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1052
  li x28, 1052
  li x1, 0x0
  li x2, 0x1
  li x3, 0
  bgeu x1, x2, L1052t
  li x3, 2
  j L1052e
  L1052t: li x3, 1
  L1052e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1053
  li x28, 1053
  li x1, 0x80000000
  li x2, 0x1
  li x3, 0
  bgeu x1, x2, L1053t
  li x3, 2
  j L1053e
  L1053t: li x3, 1
  L1053e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1054
  li x28, 1054
  li x1, 0x1
  li x2, 0x80000000
  li x3, 0
  bgeu x1, x2, L1054t
  li x3, 2
  j L1054e
  L1054t: li x3, 1
  L1054e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1055
  li x28, 1055
  li x1, 0xffffffff
  li x2, 0x0
  li x3, 0
  bgeu x1, x2, L1055t
  li x3, 2
  j L1055e
  L1055t: li x3, 1
  L1055e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1056
  li x28, 1056
  li x1, 0x0
  li x2, 0xffffffff
  li x3, 0
  bgeu x1, x2, L1056t
  li x3, 2
  j L1056e
  L1056t: li x3, 1
  L1056e: nop
  li x29, 0x2
  bne x3, x29, fail
  # case 1057
  li x28, 1057
  li x1, 0x5
  li x2, 0x5
  li x3, 0
  bgeu x1, x2, L1057t
  li x3, 2
  j L1057e
  L1057t: li x3, 1
  L1057e: nop
  li x29, 0x1
  bne x3, x29, fail
  # case 1058
  li x28, 1058
  li x1, 10
  li x3, 0
  Lloop: add x3, x3, x1
  addi x1, x1, -1
  bnez x1, Lloop
  li x29, 0x37
  bne x3, x29, fail
  # case 1059
  li x28, 1059
  jal x1, Lj1
  Lj0: j Lj2
  Lj1: auipc x3, 0
  addi x3, x3, -4
  sub x3, x1, x3
  Lj2: nop
  li x29, 0x0
  bne x3, x29, fail
  # case 1060
  li x28, 1060
  la x5, Lj3
  jalr x1, 0(x5)
  li x3, 99
  Lj3: li x3, 7
  li x29, 0x7
  bne x3, x29, fail
  # case 1061
  li x28, 1061
  la x5, Lj4
  addi x5, x5, 1
  jalr x0, -1(x5)
  li x3, 99
  Lj4: li x3, 8
  li x29, 0x8
  bne x3, x29, fail
  # case 1062
  li x28, 1062
  li x1, 5
  addi x0, x1, 5
  add x3, x0, x0
  li x29, 0x0
  bne x3, x29, fail
pass:
  li x30, 1
  la x31, tohost
  sw x30, 0(x31)
1: j 1b
fail:
  slli x30, x28, 1
  ori x30, x30, 1
  la x31, tohost
  sw x30, 0(x31)
2: j 2b
  .data
  .align 4
tdata: .word 0x00FF00FF, 0xFF00FF00, 0x0FF00FF0, 0xF00FF00F
  .word 0
sbuf: .word 0, 0
  .section .tohost, "aw"
  .globl tohost
tohost: .word 0
