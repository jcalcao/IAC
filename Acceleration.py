import math
intervalo_tempo = 0.1 #Intervalos intervalo_tempo (segundos)
angulo = 45 #graus
aceleracao_gravidade = 9.8 #m/s^2
posicao = 0 #metros
velocidade_inicial = 0 #m/s
time_limit = 5

def aceleracaoX(angulo,a_Gravidade):
    angulo = math.radians(angulo)
    aceleracao = a_Gravidade*math.sin(angulo)
    return aceleracao

def velocidadeX(velocidade_inicial, aceleracao):
    velocidade = aceleracao*intervalo_tempo
    velocidade = velocidade + velocidade_inicial
    return velocidade

def posicaoX(posicao, velocidade_inicial):
    aceleracao = aceleracaoX(angulo,aceleracao_gravidade)
    posicao = posicao + velocidade_inicial*intervalo_tempo + (aceleracao*(intervalo_tempo)**2)/2
    return posicao
    
def teste():
    global velocidade_inicial
    global posicao
    tempo = 0
    while tempo < time_limit:
        posicao = posicaoX(posicao,velocidade_inicial)
        velocidade_inicial = velocidadeX(velocidade_inicial,aceleracaoX(angulo,aceleracao_gravidade))
        print("posicao = ",posicao,"velocidade =",velocidade_inicial)
        tempo = tempo + intervalo_tempo 
        
def tabela_sen():
    for i in range(0,91):
        angulo = math.radians(i)
        seno = math.sin(angulo)
        seno = into_binary(seno)
        print(seno,"",sep=",",end="",flush=True)
        
def into_binary(seno):
    casas_decimais = 8
    n_bin = 0
    binario = list("00000000")
    while(casas_decimais > 0):
        if(seno >= 1/2):
            seno = seno - 1/2
            binario[0] = "1"
        elif(seno >= 1/4):
            seno = seno - 1/4
            binario[1] = "1"
        elif(seno >= 1/8):
            seno = seno - 1/8
            binario[2] = "1"
        elif(seno >= 1/16):
            seno = seno - 1/16
            binario[3] = "1"
        elif(seno >= 1/32):
            seno = seno - 1/32
            binario[4] = "1"
        elif(seno >= 1/64):
            seno = seno - 1/64
            binario[5] = "1"
        elif(seno >= 1/128):
            seno = seno - 1/128
            binario[6] = "1"
        elif(seno >= 1/256):
            seno = seno - 1/256
            binario[7] = "1"
        casas_decimais = casas_decimais - 1
    binario = "".join(binario)
    hexadecimal = hex(int (binario,2))
    hexadecimal = hex_tabela(hexadecimal)
    return hexadecimal

def hex_tabela(hexadecimal):
    hexadecimal = list(hexadecimal)
    i = 0
    hexadecimal[1] = "0"
    for number in hexadecimal:
        i = i + 1
    if i < 4:
        hexadecimal.insert(0,"0")   
    hexadecimal.append("H")
    hexadecimal = "".join(hexadecimal)
    return hexadecimal        