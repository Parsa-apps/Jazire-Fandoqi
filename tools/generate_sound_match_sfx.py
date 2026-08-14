#!/usr/bin/env python3
"""Generate distinct, friendly environmental cues for the sound-match game."""
import math, os, random, struct, wave
SR=22050; TAU=math.tau
OUT=os.path.join(os.path.dirname(__file__),'..','assets','audio','sound_match')

def tone(buf,start,dur,f0,f1=None,amp=.3,harm=(1,.25,.08)):
 a=int(start*SR); n=min(int(dur*SR),len(buf)-a); f1=f0 if f1 is None else f1; ph=0
 for i in range(max(0,n)):
  t=i/SR; u=i/max(1,n-1); f=f0+(f1-f0)*u; ph+=TAU*f/SR
  env=min(1,t/.015)*min(1,(dur-t)/.05)
  buf[a+i]+=amp*env*sum(h*math.sin(ph*(j+1)) for j,h in enumerate(harm))
def noise(buf,start,dur,amp=.15,seed=1,cut=.85):
 a=int(start*SR); n=min(int(dur*SR),len(buf)-a); r=random.Random(seed+a); lp=0
 for i in range(max(0,n)):
  t=i/SR; x=r.random()*2-1; lp=cut*lp+(1-cut)*x
  env=min(1,t/.01)*min(1,(dur-t)/.04); buf[a+i]+=amp*lp*env
def silence(d=1.8): return [0.0]*int(d*SR)
def save(name,b):
 # soft room echo + limiter
 o=b[:]; d=int(.09*SR)
 for i in range(d,len(b)): b[i]+=o[i-d]*.12
 peak=max((abs(x) for x in b),default=1); g=.62/max(.001,peak)
 os.makedirs(OUT,exist_ok=True)
 with wave.open(os.path.join(OUT,name+'.wav'),'w') as w:
  w.setparams((1,2,SR,len(b),'NONE','none')); w.writeframes(b''.join(struct.pack('<h',int(max(-1,min(1,math.tanh(x*g)))*32767)) for x in b))

def animal(name,calls):
 b=silence()
 for st,d,f0,f1 in calls: tone(b,st,d,f0,f1,.34,(1,.38,.14))
 save(name,b)

# Stylised but recognisable, non-startling animal calls.
animal('dog',[(.18,.18,240,175),(.52,.22,230,155),(.93,.15,255,190)])
animal('cat',[(.12,.72,420,760),(.92,.55,720,390)])
animal('cow',[(.12,.7,135,92),(.92,.62,125,82)])
animal('chicken',[(.12,.12,680,920),(.30,.10,760,1080),(.48,.18,620,1120),(.85,.10,780,1040)])
animal('duck',[(.15,.18,310,225),(.43,.16,330,235),(.72,.20,300,210)])
animal('frog',[(.12,.24,105,155),(.42,.24,98,148),(.88,.3,92,142)])
animal('horse',[(.12,.55,260,520),(.62,.48,510,235)]); 
b=silence(); noise(b,.1,.55,.12,4,.72); tone(b,.18,.38,300,620,.25); noise(b,.75,.42,.1,7,.7); save('horse',b)
animal('sheep',[(.1,.65,285,410),(.84,.62,300,425)])
# Vehicles and everyday sounds.
b=silence(); tone(b,.05,1.6,105,135,.22,(1,.3,.1)); noise(b,.05,1.6,.12,1,.94); tone(b,.45,.25,420,420,.16); save('car',b)
b=silence(); tone(b,.05,1.65,82,95,.25,(1,.35,.12)); noise(b,.05,1.65,.10,2,.95); tone(b,.3,.5,285,285,.20); save('bus',b)
b=silence(); noise(b,.05,1.7,.2,3,.97); tone(b,.05,1.7,145,220,.11,(1,.15)); save('airplane',b)
b=silence();
for i in range(7): tone(b,.08+i*.22,.07,760,620,.16)
tone(b,.1,1.55,95,110,.13); save('train',b)
b=silence();
for i in range(5): tone(b,.1+i*.32,.035,1250,1250,.22,(1,.15))
save('clock',b)
b=silence();
for i in range(3): tone(b,.1+i*.52,.28,660,880,.18,(1,.2))
save('phone',b)
b=silence(); noise(b,.04,1.72,.22,8,.96); tone(b,.04,1.72,75,310,.16,(1,.2)); save('rocket',b)
b=silence(); noise(b,.04,1.7,.16,9,.90); tone(b,.1,1.55,180,150,.09,(1,.15)); save('boat',b)
print('generated',len(os.listdir(OUT)),'sound-match cues')
