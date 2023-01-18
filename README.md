# vide

Automatically search for web servers in `.xml` results of `nmap` data and lightly scan them using `nikto`, `nuclei`, `whatweb` or `ffuf` and also take screenshots using `chromium`

        _______________
    ==c(___(o(______(_()
            \=\
             )=\
            //|\\   ~vide~ high-level web server enumeration
           //|| \\  
          // ||  \\
         //  ||   \\
        //         \\

This is yet another ctf/engagement automation tool, born out of curiosity and boredom

## Usage

```bash
$ tree target 
target
└── nmap
    ├── init.gnmap
    ├── init.nmap
    └── init.xml

$ ./vide -h
usage: vide <path to dir with `nmap` folder>
       [-h]                          show this message
       [-w]                          do [w]hatweb scan
       [-o]                          do nikt[o] scan
       [-i]                          do nucle[o] scan
       [-f]                          do directory brute [f]orcing
       [-d]                          [d]isable screenshotting
       [-p <path to webservers.txt>] [p]ass list of web servers

$ ./vide target -w -i -o -f
[...]

$ tree target
target/
├── nmap
│   ├── host_port.txt
│   ├── init.gnmap
│   ├── init.nmap
│   └── init.xml
└── vide_18.01_1640
    ├── ffuf
    │   └── 127.0.0.1_9090.html
    ├── httpx
    │   └── scan.log
    ├── nikto
    │   └── 127.0.0.1_9090.html
    ├── nuclei
    │   └── http:
    │       └── 127.0.0.1:9090
    │           ├── [...].md
    │           └── tech-detect-http___127.0.0.1_9090-simplehttp.md
    ├── screens
    │   └── http
    │       └── 127.0.0.1_9090.pdf
    ├── webservers.txt
    └── whatweb
        └── 127.0.0.1_9090
            ├── brief.log
            └── deep.log
```

![demo](https://github.com/dreizehnutters/vide/blob/main/assets/demo.gif)

---

## Installation

```bash
$ git clone https://github.com/dreizehnutters/vide
```

## Requirements

+ `/usr/bin/xmlstarlet`
+ `$GO_PATH/bin/httpx`
+ `/usr/bin/chromium`
+ `/usr/bin/whatweb`
+ `/usr/bin/nikto`
+ `$GO_PATH/bin/nuclei`
+ `/usr/bin/ffuf`
---

## Features

- `httpx` 		used for web server identification
- `chromium` 	used for taking screenshots
- `nuclei` 		used for web server scanning
- `nikto` 		used for web server scanning
- `ffuf` 		used for directory brute forcing
- `whatweb` 	used for web server scanning