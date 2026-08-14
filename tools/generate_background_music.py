#!/usr/bin/env python3
"""Generate gentle, loopable, child-safe background music for Jazire Fandoqi.

The score is intentionally instrumental and speech-friendly: pentatonic melodies,
soft toy percussion, no vocals, alarms, abrupt transients, or heavy bass. Output is
22.05 kHz/16-bit/mono WAV to keep the offline APK compact.
"""
from __future__ import annotations
import math, os, random, struct, wave

SR = 22050
TAU = math.tau
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio', 'bgm')


def note(midi: int) -> float:
    return 440.0 * 2 ** ((midi - 69) / 12)


def add_tone(buf, start, dur, midi, amp=.1, kind='kalimba', pan=0):
    a = int(start * SR); n = min(int(dur * SR), len(buf) - a)
    if n <= 0: return
    f = note(midi); phase = 0.0
    for i in range(n):
        t = i / SR
        if kind == 'pad':
            env = min(1., t/.35) * min(1., (dur-t)/.5)
            v = math.sin(TAU*f*t) + .28*math.sin(TAU*f*2*t+.2) + .12*math.sin(TAU*f*.5*t)
        elif kind == 'flute':
            env = min(1., t/.08) * min(1., (dur-t)/.16)
            vibrato = .004 * math.sin(TAU*5.1*t)
            v = math.sin(TAU*f*(1+vibrato)*t) + .13*math.sin(TAU*f*2*t)
        elif kind == 'pizz':
            env = min(1., t/.008) * math.exp(-t/0.34)
            v = math.sin(TAU*f*t) + .34*math.sin(TAU*f*2*t) + .10*math.sin(TAU*f*3*t)
        else: # rounded wooden kalimba / music box
            env = min(1., t/.006) * math.exp(-t/(.42 if kind == 'kalimba' else .72))
            v = math.sin(TAU*f*t) + .24*math.sin(TAU*f*2.01*t) + .08*math.sin(TAU*f*3.98*t)
        buf[a+i] += amp * env * v


def add_drum(buf, start, amp=.06, bright=False):
    a=int(start*SR); n=min(int(.16*SR),len(buf)-a); rng=random.Random(a+17)
    phase=0.
    for i in range(max(0,n)):
        t=i/SR; phase += TAU*(115-65*min(t/.16,1))/SR
        body=math.sin(phase)*math.exp(-t/0.055)
        noise=(rng.random()*2-1)*math.exp(-t/(.018 if bright else .028))
        buf[a+i] += amp*(.72*body+.28*noise)


def add_shaker(buf, start, amp=.018):
    a=int(start*SR); n=min(int(.08*SR),len(buf)-a); rng=random.Random(a+31); prev=0.
    for i in range(max(0,n)):
        t=i/SR; x=rng.random()*2-1; hp=x-prev*.86; prev=x
        buf[a+i] += amp*hp*math.exp(-t/.025)


def add_sparkle(buf, start, midi, amp=.025):
    for delay, interval, gain in ((0,0,1),(.045,12,.55),(.09,19,.28)):
        add_tone(buf,start+delay,.5,midi+interval,amp*gain,'musicbox')


def reverb(buf, amount=.13):
    original=buf[:]
    for delay,gain in ((.105,amount),(.173,amount*.62),(.263,amount*.38)):
        d=int(delay*SR)
        for i in range(d,len(buf)): buf[i] += original[i-d]*gain


def master(buf, target_rms=.11, peak_ceiling=.66):
    # Gentle DC removal and saturation, then loudness matching. The calmer
    # sections are intentionally mastered quieter than the games track.
    lp=0.; out=[]
    for x in buf:
        lp += .0015*(x-lp); out.append(math.tanh((x-lp)*1.10))
    rms=math.sqrt(sum(x*x for x in out)/max(1,len(out))) or 1
    peak=max(abs(x) for x in out) or 1
    gain=min(target_rms/rms, peak_ceiling/peak)
    # Tiny edge fade prevents decoder clicks at the loop boundary.
    edge=int(.055*SR)
    for i in range(len(out)):
        g=min(1., i/edge, (len(out)-1-i)/edge)
        out[i]*=gain*max(0,g)
    return out


def write(name, buf, target_rms):
    os.makedirs(OUT,exist_ok=True); data=master(buf,target_rms)
    path=os.path.join(OUT,name)
    with wave.open(path,'w') as w:
        w.setparams((1,2,SR,len(data),'NONE','not compressed'))
        w.writeframes(b''.join(struct.pack('<h',max(-32767,min(32767,int(x*32767)))) for x in data))
    print(name, f'{len(data)/SR:.1f}s', os.path.getsize(path))


def compose(name,bpm,bars,root,progression,scale,style):
    beat=60/bpm; bar=beat*4; duration=bars*bar
    b=[0.] * int(duration*SR)
    rng=random.Random(sum(map(ord,name)))
    # warm sustained harmonic bed
    for k,chord in enumerate(progression*(bars//len(progression)+1)):
        if k>=bars: break
        for interval in chord:
            add_tone(b,k*bar,bar+.28,root-12+interval,.022 if style!='stories' else .027,'pad')
    # bass pulse, deliberately quiet to leave room for speech
    for k in range(bars):
        chord=progression[k%len(progression)]
        add_tone(b,k*bar,beat*1.8,root-24+chord[0],.035,'pizz')
        add_tone(b,k*bar+2*beat,beat*1.6,root-24+chord[0],.026,'pizz')
    # Distinct, singable phrases. Strategic rests keep the score from becoming
    # tiring and leave acoustic space for Persian narration.
    phrases={
        'home':     (0,2,4,None,3,2,1,None),
        'games':    (0,1,2,4,3,2,1,4),
        'cartoons': (0,3,2,None,4,3,1,None),
        'stories':  (0,None,2,None,4,None,1,None),
        'learning': (0,None,2,3,4,None,2,None),
    }
    phrase=phrases[style]
    for k in range(bars):
        for q,step in enumerate(phrase):
            # Every eighth bar takes a short breath before the next phrase.
            if step is None or (k%8==7 and q>=4): continue
            swing=(.07*beat if style=='cartoons' and q%2 else 0)
            t=k*bar+q*beat/2+swing
            idx=(step + (k%4) + (1 if k%8>=4 else 0))%len(scale)
            midi=root+12+scale[idx]
            kind={'home':'kalimba','games':'musicbox','cartoons':'pizz','stories':'musicbox','learning':'kalimba'}[style]
            level={'home':.050,'games':.054,'cartoons':.046,'stories':.034,'learning':.043}[style]
            add_tone(b,t,beat*(.68 if style=='games' else 1.12),midi,level,kind)
        if k%4==3: add_sparkle(b,(k+1)*bar-.45,root+19,.014 if style=='stories' else .018)
    # light rhythmic identity per section
    if style in ('games','cartoons'):
        for q in range(bars*8):
            t=q*beat/2
            if q%2==0: add_drum(b,t,.036 if style=='games' else .026, q%8==4)
            add_shaker(b,t+.01,.014 if style=='games' else .010)
    elif style in ('home','learning'):
        for q in range(bars*4):
            if q%2==0: add_shaker(b,q*beat+.02,.008)
    if style=='cartoons':
        # a friendly reed-like answer phrase
        for k in range(0,bars,4):
            for j,iv in enumerate((7,9,7,4,2,4,0)):
                add_tone(b,k*bar+(8+j)*beat/2,beat*.9,root+12+iv,.025,'flute')
    if style=='stories':
        for k in range(0,bars,2):
            add_tone(b,k*bar+bar*.5,bar*.8,root+24+scale[(k//2)%len(scale)],.019,'flute')
    reverb(b,.10 if style in ('games','cartoons') else .14)
    target_rms={'home':.105,'games':.120,'cartoons':.100,'stories':.075,'learning':.095}[style]
    write(name,b,target_rms)


if __name__=='__main__':
    compose('home_island.wav',84,12,60,[(0,4,7),(5,9,12),(7,11,14),(0,4,9)],[0,2,4,7,9], 'home')
    compose('games_adventure.wav',108,16,62,[(0,4,7),(5,9,12),(7,11,14),(0,4,7)],[0,2,4,7,9], 'games')
    compose('cartoon_cinema.wav',96,14,65,[(0,4,7),(2,5,9),(5,9,12),(7,11,14)],[0,2,4,7,9], 'cartoons')
    compose('story_dreams.wav',72,10,60,[(0,4,7),(5,9,12),(2,7,9),(0,4,9)],[0,2,4,7,9], 'stories')
    compose('learning_garden.wav',88,12,60,[(0,4,7),(2,5,9),(5,9,12),(7,11,14)],[0,2,4,7,9], 'learning')
