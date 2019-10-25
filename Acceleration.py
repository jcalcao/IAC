import math
tempo = 0# segundos

def aceleracaoX(angulo,a_Gravidade):
    angulo = math.radians(angulo)
    aceleracao = a_Gravidade*math.sin(angulo)
    return aceleracao

def velocidadeX(velocidade_inicial, aceleracao):
    velocidade = aceleracao*tempo
    velocidade = velocidade + velocidade_inicial
    return velocidade

def posicaoX(posicao, velocidade_inicial):
    angulo = 45
    aceleracao_gravidade = 9.8
    aceleracao = aceleracaoX(angulo,aceleracao_gravidade)
    velocidade = velocidadeX(velocidade_inicial,aceleracao)
    new_pos = velocidade*tempo
    new_pos = new_pos/2
    posicao = posicao + new_pos
    return posicao
    
def teste():
    global tempo
    for tempo in range(0,10):
        x = posicaoX(0,0)
        print(x)
    