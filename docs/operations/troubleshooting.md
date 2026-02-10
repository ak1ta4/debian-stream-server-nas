# Troubleshooting

## Sunshine no conecta

Verificar proceso:
```
ps aux | grep sunshine
```

Ver logs:
```
tail -f ~/.config/sunshine/sunshine.log
```

Reiniciar:
```
pkill sunshine
sunshine &
```

## Docker no arranca

Ver estado:
```
docker ps -a
docker logs homepage
```

Reiniciar:
```
sudo systemctl restart docker
docker start homepage
```

## SSH no responde

Verificar:
```
sudo systemctl status ssh
```

Reiniciar:
```
sudo systemctl restart ssh
```

## Sistema lento

Ver recursos:
```
htop
free -h
df -h
```

## Input no funciona

Verificar grupo:
```
groups | grep input
```

Verificar uinput:
```
lsmod | grep uinput
```
