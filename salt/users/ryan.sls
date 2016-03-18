ryan-group:
  group:
    - present
    - name: ryan
    - gid: 1000
    
ryan:
  user:
    - present
    - fullname: Ryan McGuire
    - shell: /bin/bash
    - home: /home/ryan
    - uid: 1000
    - gid: 1000
    - password: ryan
    - groups:
      - wheel
      
