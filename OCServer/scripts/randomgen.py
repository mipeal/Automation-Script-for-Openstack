from secrets import choice
#import 

#ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.lower()
NUM = '0123456789'
SPECIAL = '!"%&/:*+'
DELIMITER = '-_.'

WORDS = set()
with open('words.txt', 'r') as f:
    for w in f:
        w = w.split()[-1] #ta bort tallene før bokstavenee
      #  print(w)
        if (len(w) < 7):
            if (len(w) > 3):
                WORDS.add(w.strip().lower())
WORDS = list(WORDS)
print(len(WORDS))

for _ in range(24):
    pw = ''
    pw += choice(WORDS).strip()
    pw += choice(DELIMITER)
    pw += choice(WORDS).strip()
    pw += choice(DELIMITER)
    pw += choice(WORDS).strip()
    pw += choice(DELIMITER)
    pw += choice(NUM)
    pw += choice(SPECIAL)
    print(pw)
    with open("randompassword.txt", 'a') as f:
        print(pw, file=f)

for _ in range(24):
    pw = ''
    pw += choice(WORDS).strip()
    pw += choice(DELIMITER)
    pw += choice(WORDS).strip()
    with open("randomusern.txt", 'a') as f:
        print(pw, file=f)
