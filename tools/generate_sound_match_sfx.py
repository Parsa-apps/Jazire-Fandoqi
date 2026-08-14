#!/usr/bin/env python3
"""Generate v2 child-safe environmental cues for the sound-match game.

Each cue uses a different acoustic model (formants, filtered noise, pitch contour
and rhythm), rather than a generic beep. The output stays short, soft and free of
startling transients for children aged 3–8.
"""
from __future__ import annotations
import math, os, random, struct, wave

SR = 22050
TAU = math.tau
DURATION = 2.2
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio', 'sound_match')


def buf(): return [0.0] * int(DURATION * SR)
def smoothstep(x):
    x=max(0.,min(1.,x)); return x*x*(3-2*x)
def env(t,d,a=.015,r=.08): return smoothstep(t/a)*smoothstep((d-t)/r)

def voiced(b,start,dur,pitch,amp=.25,harmonics=(1,.34,.15,.06),tremolo=0.):
    a=int(start*SR); n=min(int(dur*SR),len(b)-a); phases=[0.]*len(harmonics)
    for i in range(max(0,n)):
        t=i/SR; u=i/max(1,n-1); f=pitch(u,t) if callable(pitch) else pitch
        v=0.
        for h,g in enumerate(harmonics,1):
            phases[h-1]+=TAU*f*h/SR; v+=g*math.sin(phases[h-1])
        am=.78+.22*math.sin(TAU*tremolo*t) if tremolo>0 else 1.
        b[a+i]+=amp*env(t,dur)*v*am

def filtered_noise(b,start,dur,amp=.15,seed=1,color=.90,highpass=False):
    a=int(start*SR); n=min(int(dur*SR),len(b)-a); rng=random.Random(seed+a); lp=0.; prev=0.
    for i in range(max(0,n)):
        t=i/SR; x=rng.random()*2-1; lp=color*lp+(1-color)*x
        y=(x-lp if highpass else lp); y2=y-.25*prev; prev=y
        b[a+i]+=amp*env(t,dur,.008,.06)*y2

def pulse_noise(b,start,dur,rate,amp,seed,color=.86):
    a=int(start*SR); n=min(int(dur*SR),len(b)-a); rng=random.Random(seed); lp=0.
    for i in range(max(0,n)):
        t=i/SR; x=rng.random()*2-1; lp=color*lp+(1-color)*x
        pulse=max(0.,math.sin(TAU*rate*t))**2.4
        b[a+i]+=amp*env(t,dur)*lp*(.18+.82*pulse)

def echo(b,delay=.075,gain=.09):
    src=b[:]; d=int(delay*SR)
    for i in range(d,len(b)): b[i]+=src[i-d]*gain

def save(name,b,peak=.56):
    # DC blocker + very gentle saturation; preserve loudness differences.
    out=[]; lp=0.
    for x in b:
        lp += .002*(x-lp); out.append(math.tanh((x-lp)*1.12))
    p=max((abs(x) for x in out),default=1.)
    rms=math.sqrt(sum(x*x for x in out)/max(1,len(out))) or 1.
    # Sustained calls (especially sheep/frog) must not feel louder than short
    # ticks or barks on headphones.
    g=min(peak/max(.001,p), .17/rms)
    edge=int(.008*SR)
    for i in range(len(out)):
        e=min(1.,i/max(1,edge),(len(out)-1-i)/max(1,edge)); out[i]*=g*max(0,e)
    os.makedirs(OUT,exist_ok=True); path=os.path.join(OUT,name+'.wav')
    with wave.open(path,'w') as w:
        w.setparams((1,2,SR,len(out),'NONE','not compressed'))
        w.writeframes(b''.join(struct.pack('<h',int(max(-1,min(1,x))*32767)) for x in out))

# ── Animals: species-specific contour, timbre and rhythm ──────────────────
def dog():
    b=buf()
    for j,st in enumerate((.16,.62,1.13)):
        voiced(b,st,.25,lambda u,t: 270-125*smoothstep(u),.31,(1,.48,.24,.10))
        filtered_noise(b,st,.20,.20,10+j,.73)
    echo(b); save('dog',b)
def cat():
    b=buf()
    contour=lambda u,t: 390+390*math.sin(math.pi*u)**1.4-75*u
    voiced(b,.12,.88,contour,.27,(1,.46,.18,.08),5.2)
    voiced(b,1.18,.72,lambda u,t: 520-190*u,.20,(1,.36,.12),5.8)
    echo(b,.095,.07); save('cat',b)
def cow():
    b=buf()
    voiced(b,.10,1.72,lambda u,t: 118-28*smoothstep(u)+3*math.sin(TAU*4*t),.31,(1,.58,.27,.13),4.0)
    filtered_noise(b,.12,1.65,.06,22,.80); echo(b,.11,.10); save('cow',b)
def chicken():
    b=buf()
    for j,st in enumerate((.10,.31,.55,.94,1.16,1.42)):
        voiced(b,st,.11 if j!=3 else .18,lambda u,t: 620+520*u,.25,(1,.31,.11))
        filtered_noise(b,st,.09,.13,31+j,.66)
    save('chicken',b)
def duck():
    b=buf()
    for j,st in enumerate((.12,.48,.88,1.31)):
        voiced(b,st,.24,lambda u,t: 340-105*u+12*math.sin(TAU*18*t),.29,(1,.62,.31,.16))
        filtered_noise(b,st,.20,.12,42+j,.76)
    echo(b,.065,.07); save('duck',b)
def frog():
    b=buf()
    for j,st in enumerate((.12,.68,1.28)):
        voiced(b,st,.38,lambda u,t: 86+34*math.sin(math.pi*u),.34,(1,.52,.21),22)
        pulse_noise(b,st,.34,22,.08,50+j,.92)
    save('frog',b)
def horse():
    b=buf()
    contour=lambda u,t: 310+430*math.sin(math.pi*min(1,u*1.15))**.75-125*u+18*math.sin(TAU*12*t)
    voiced(b,.10,1.45,contour,.23,(1,.42,.22,.10),11)
    filtered_noise(b,.12,1.35,.10,61,.78); echo(b,.12,.09); save('horse',b)
def sheep():
    b=buf()
    for st,d in ((.10,.78),(1.02,.88)):
        voiced(b,st,d,lambda u,t: 245+18*math.sin(TAU*18*t)-28*u,.29,(1,.50,.22,.09),18)
    echo(b,.085,.08); save('sheep',b)

# ── Familiar objects and vehicles ─────────────────────────────────────────
def car():
    b=buf(); voiced(b,.05,2.05,lambda u,t: 82+40*smoothstep(u),.14,(1,.42,.18))
    pulse_noise(b,.05,2.05,32,.12,71,.94)
    for st in (.58,1.12): voiced(b,st,.24,430,.16,(1,.20))
    save('car',b)
def bus():
    b=buf(); voiced(b,.03,2.10,lambda u,t: 62+5*math.sin(TAU*7*t),.20,(1,.50,.23))
    pulse_noise(b,.04,1.65,14,.13,81,.95)
    filtered_noise(b,1.48,.55,.24,82,.72,True) # pneumatic door
    save('bus',b)
def airplane():
    b=buf(); filtered_noise(b,.03,2.12,.34,91,.95)
    voiced(b,.04,2.10,lambda u,t: 145+72*smoothstep(u),.09,(1,.19),7)
    echo(b,.045,.06); save('airplane',b)
def train():
    b=buf(); voiced(b,.04,2.10,88,.10,(1,.26))
    for j in range(8):
        st=.08+j*.25; filtered_noise(b,st,.075,.27,100+j,.63)
        voiced(b,st,.07,520 if j%2 else 680,.09,(1,.15))
    voiced(b,.32,.82,lambda u,t: 780+210*math.sin(math.pi*u),.13,(1,.20))
    save('train',b)
def clock():
    b=buf()
    for j,st in enumerate((.12,.48,.84,1.20,1.56,1.92)):
        voiced(b,st,.055,1320 if j%2==0 else 930,.28,(1,.12))
        filtered_noise(b,st,.028,.10,120+j,.58)
    save('clock',b,.52)
def phone():
    b=buf()
    for st in (.10,.82,1.54):
        voiced(b,st,.42,440,.16,(1,.08)); voiced(b,st,.42,520,.14,(1,.08))
    echo(b,.07,.06); save('phone',b,.52)
def rocket():
    b=buf(); filtered_noise(b,.04,2.12,.38,141,.92)
    pulse_noise(b,.05,2.10,28,.16,142,.96)
    voiced(b,.04,2.10,lambda u,t: 58+88*smoothstep(u),.11,(1,.31,.12))
    save('rocket',b)
def boat():
    b=buf(); pulse_noise(b,.03,2.12,1.7,.24,151,.91) # water laps
    voiced(b,.25,1.38,148,.18,(1,.42,.15)) # gentle fog horn
    filtered_noise(b,.03,2.10,.11,152,.87); echo(b,.14,.12); save('boat',b)

if __name__=='__main__':
    for make in (dog,cat,cow,chicken,duck,frog,horse,sheep,car,bus,airplane,train,clock,phone,rocket,boat): make()
    print('generated 16 v2 sound-match cues')
