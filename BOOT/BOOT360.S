ConstCabecas = 2
ConstSetoresPorTrilha = 9
.include BOOT.S

| Argumentos Extras
.ascii " 40 2 9"
.byte 13
.byte 0

FimArgumento:
.zerob 1024-FimArgumento