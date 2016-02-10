--Envio de Paquetes UDP con medicion ADC
local AN0=0
local VOLTAJE=0
local CONT=0
local CONECTADO=false
local INICIO=true

pinLED=8
gpio.mode(pinLED,gpio.OUTPUT)


function LeeADC()
AN0=adc.read(0)
VOLTAJE=3300*AN0/1024
end

tmr.alarm(0,3000, 1, function()
  if INICIO==true then
    print("Inicio")
    wifi.setmode(wifi.STATION) 
    wifi.sta.config("CELECSIS","74737473") 
    wifi.sta.autoconnect(1)
    INICIO=false
  end 
  if wifi.sta.getip()~=nil then
    print("Conectado a WiFi")
    print(wifi.sta.getip())
    CONECTADO=true
    gpio.write(pinLED,gpio.HIGH) --Led WiFi On
    tmr.stop(0)
   end
end)


tmr.alarm(1, 500, 1, function() 
    if CONECTADO==true then
      LeeADC()
      CONT=CONT+1  --Contador de Muestras
      conn = net.createConnection(net.UDP,0)
      conn:connect(12345,"192.168.1.137")
      local msg = CONT.." VOLTAJE="..VOLTAJE.." mV"
      print(msg)
      conn:send(msg)
      conn:close() 
    end
end)

