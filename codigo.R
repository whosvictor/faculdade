install.packages("readxl")
library(readxl)
a <- read_xlsx("C:\\Users/Aluno/Downloads/Tabelas_Galáctica (6).xlsx")
#Essas linhas acima baixam a biblioteca de leitura
#lêem a tabela e a armazenam na variável 'a'


mat <- matrix (c(1,2)) #Seta uma matrix de ordem (1x2)

layout(mat, c(1,1), c(2.5,1)) #função Layout pra compor grafico, primeiro parametro é a matrix usada

topox=ceiling(max(a)) # funçãoretorna o menor inteiro que é maior ou igual ao valor passado como argumento

par(mar=c(0, 5, 2, 1))

b<-hist(a, breaks=c(0, seq(4,topox, 4)),
        include.lowest=TRUE, right=FALSE, plot=FALSE)

topoy=max(c(b$counts))
porcent=round((C(b$counts)/length(a))*100, 2)

hist (a, xlim = c(0,topox), ylim = c(topoy), breaks=c(0, seq(4, topox, 4)),
      include.lowest = TRUE, right = FALSE, xlab = "", ylab ="Frequência", col = "orange",
      main = "Salário", axes=FALSE, density=30)

axis(1, at=seq(0,topox,by=4))
axis(2, at=seq(0,topox,by=2))

j<-2
k<-0.5

for (i in 1:16){
  text(j, k, paste(porcent[i], "%"))
  j<-j+4
}

par(mar=c(0, 5, 0, 1))
c<-boxplot (a, horizontal = TRUE, outline = FALSE, xslim =c(0,2), col = "orange", axes=FALSE)