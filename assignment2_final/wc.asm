
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 48             	sub    $0x48,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
   6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
   d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  inword = 0;
  19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  20:	eb 68                	jmp    8a <wc+0x8a>
    for(i=0; i<n; i++){
  22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  29:	eb 57                	jmp    82 <wc+0x82>
      c++;
  2b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
      if(buf[i] == '\n')
  2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  32:	05 00 12 00 00       	add    $0x1200,%eax
  37:	0f b6 00             	movzbl (%eax),%eax
  3a:	3c 0a                	cmp    $0xa,%al
  3c:	75 04                	jne    42 <wc+0x42>
        l++;
  3e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  45:	05 00 12 00 00       	add    $0x1200,%eax
  4a:	0f b6 00             	movzbl (%eax),%eax
  4d:	0f be c0             	movsbl %al,%eax
  50:	89 44 24 04          	mov    %eax,0x4(%esp)
  54:	c7 04 24 8c 0d 00 00 	movl   $0xd8c,(%esp)
  5b:	e8 47 02 00 00       	call   2a7 <strchr>
  60:	85 c0                	test   %eax,%eax
  62:	74 09                	je     6d <wc+0x6d>
        inword = 0;
  64:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  6b:	eb 11                	jmp    7e <wc+0x7e>
      else if(!inword){
  6d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  71:	75 0b                	jne    7e <wc+0x7e>
        w++;
  73:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
        inword = 1;
  77:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
  7e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  85:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  88:	7c a1                	jl     2b <wc+0x2b>
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
  8a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  91:	00 
  92:	c7 44 24 04 00 12 00 	movl   $0x1200,0x4(%esp)
  99:	00 
  9a:	8b 45 08             	mov    0x8(%ebp),%eax
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 9b 03 00 00       	call   440 <read>
  a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  ac:	0f 8f 70 ff ff ff    	jg     22 <wc+0x22>
        w++;
        inword = 1;
      }
    }
  }
  if(n < 0){
  b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  b6:	79 19                	jns    d1 <wc+0xd1>
    printf(1, "wc: read error\n");
  b8:	c7 44 24 04 92 0d 00 	movl   $0xd92,0x4(%esp)
  bf:	00 
  c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c7:	e8 13 05 00 00       	call   5df <printf>
    exit();
  cc:	e8 57 03 00 00       	call   428 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  d4:	89 44 24 14          	mov    %eax,0x14(%esp)
  d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  db:	89 44 24 10          	mov    %eax,0x10(%esp)
  df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  ed:	c7 44 24 04 a2 0d 00 	movl   $0xda2,0x4(%esp)
  f4:	00 
  f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fc:	e8 de 04 00 00       	call   5df <printf>
}
 101:	c9                   	leave  
 102:	c3                   	ret    

00000103 <main>:

int
main(int argc, char *argv[])
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 e4 f0             	and    $0xfffffff0,%esp
 109:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
 10c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 110:	7f 19                	jg     12b <main+0x28>
    wc(0, "");
 112:	c7 44 24 04 af 0d 00 	movl   $0xdaf,0x4(%esp)
 119:	00 
 11a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 121:	e8 da fe ff ff       	call   0 <wc>
    exit();
 126:	e8 fd 02 00 00       	call   428 <exit>
  }

  for(i = 1; i < argc; i++){
 12b:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 132:	00 
 133:	eb 7d                	jmp    1b2 <main+0xaf>
    if((fd = open(argv[i], 0)) < 0){
 135:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 139:	c1 e0 02             	shl    $0x2,%eax
 13c:	03 45 0c             	add    0xc(%ebp),%eax
 13f:	8b 00                	mov    (%eax),%eax
 141:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 148:	00 
 149:	89 04 24             	mov    %eax,(%esp)
 14c:	e8 17 03 00 00       	call   468 <open>
 151:	89 44 24 18          	mov    %eax,0x18(%esp)
 155:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 15a:	79 29                	jns    185 <main+0x82>
      printf(1, "cat: cannot open %s\n", argv[i]);
 15c:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 160:	c1 e0 02             	shl    $0x2,%eax
 163:	03 45 0c             	add    0xc(%ebp),%eax
 166:	8b 00                	mov    (%eax),%eax
 168:	89 44 24 08          	mov    %eax,0x8(%esp)
 16c:	c7 44 24 04 b0 0d 00 	movl   $0xdb0,0x4(%esp)
 173:	00 
 174:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 17b:	e8 5f 04 00 00       	call   5df <printf>
      exit();
 180:	e8 a3 02 00 00       	call   428 <exit>
    }
    wc(fd, argv[i]);
 185:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 189:	c1 e0 02             	shl    $0x2,%eax
 18c:	03 45 0c             	add    0xc(%ebp),%eax
 18f:	8b 00                	mov    (%eax),%eax
 191:	89 44 24 04          	mov    %eax,0x4(%esp)
 195:	8b 44 24 18          	mov    0x18(%esp),%eax
 199:	89 04 24             	mov    %eax,(%esp)
 19c:	e8 5f fe ff ff       	call   0 <wc>
    close(fd);
 1a1:	8b 44 24 18          	mov    0x18(%esp),%eax
 1a5:	89 04 24             	mov    %eax,(%esp)
 1a8:	e8 a3 02 00 00       	call   450 <close>
  if(argc <= 1){
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
 1ad:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
 1b2:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1b6:	3b 45 08             	cmp    0x8(%ebp),%eax
 1b9:	0f 8c 76 ff ff ff    	jl     135 <main+0x32>
      exit();
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit();
 1bf:	e8 64 02 00 00       	call   428 <exit>

000001c4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1c4:	55                   	push   %ebp
 1c5:	89 e5                	mov    %esp,%ebp
 1c7:	57                   	push   %edi
 1c8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1cc:	8b 55 10             	mov    0x10(%ebp),%edx
 1cf:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d2:	89 cb                	mov    %ecx,%ebx
 1d4:	89 df                	mov    %ebx,%edi
 1d6:	89 d1                	mov    %edx,%ecx
 1d8:	fc                   	cld    
 1d9:	f3 aa                	rep stos %al,%es:(%edi)
 1db:	89 ca                	mov    %ecx,%edx
 1dd:	89 fb                	mov    %edi,%ebx
 1df:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1e2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1e5:	5b                   	pop    %ebx
 1e6:	5f                   	pop    %edi
 1e7:	5d                   	pop    %ebp
 1e8:	c3                   	ret    

000001e9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1f5:	90                   	nop
 1f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f9:	0f b6 10             	movzbl (%eax),%edx
 1fc:	8b 45 08             	mov    0x8(%ebp),%eax
 1ff:	88 10                	mov    %dl,(%eax)
 201:	8b 45 08             	mov    0x8(%ebp),%eax
 204:	0f b6 00             	movzbl (%eax),%eax
 207:	84 c0                	test   %al,%al
 209:	0f 95 c0             	setne  %al
 20c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 210:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 214:	84 c0                	test   %al,%al
 216:	75 de                	jne    1f6 <strcpy+0xd>
    ;
  return os;
 218:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 21b:	c9                   	leave  
 21c:	c3                   	ret    

0000021d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 220:	eb 08                	jmp    22a <strcmp+0xd>
    p++, q++;
 222:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 226:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 22a:	8b 45 08             	mov    0x8(%ebp),%eax
 22d:	0f b6 00             	movzbl (%eax),%eax
 230:	84 c0                	test   %al,%al
 232:	74 10                	je     244 <strcmp+0x27>
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	0f b6 10             	movzbl (%eax),%edx
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	0f b6 00             	movzbl (%eax),%eax
 240:	38 c2                	cmp    %al,%dl
 242:	74 de                	je     222 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 244:	8b 45 08             	mov    0x8(%ebp),%eax
 247:	0f b6 00             	movzbl (%eax),%eax
 24a:	0f b6 d0             	movzbl %al,%edx
 24d:	8b 45 0c             	mov    0xc(%ebp),%eax
 250:	0f b6 00             	movzbl (%eax),%eax
 253:	0f b6 c0             	movzbl %al,%eax
 256:	89 d1                	mov    %edx,%ecx
 258:	29 c1                	sub    %eax,%ecx
 25a:	89 c8                	mov    %ecx,%eax
}
 25c:	5d                   	pop    %ebp
 25d:	c3                   	ret    

0000025e <strlen>:

uint
strlen(char *s)
{
 25e:	55                   	push   %ebp
 25f:	89 e5                	mov    %esp,%ebp
 261:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 264:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 26b:	eb 04                	jmp    271 <strlen+0x13>
 26d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 271:	8b 45 fc             	mov    -0x4(%ebp),%eax
 274:	03 45 08             	add    0x8(%ebp),%eax
 277:	0f b6 00             	movzbl (%eax),%eax
 27a:	84 c0                	test   %al,%al
 27c:	75 ef                	jne    26d <strlen+0xf>
    ;
  return n;
 27e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 281:	c9                   	leave  
 282:	c3                   	ret    

00000283 <memset>:

void*
memset(void *dst, int c, uint n)
{
 283:	55                   	push   %ebp
 284:	89 e5                	mov    %esp,%ebp
 286:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 289:	8b 45 10             	mov    0x10(%ebp),%eax
 28c:	89 44 24 08          	mov    %eax,0x8(%esp)
 290:	8b 45 0c             	mov    0xc(%ebp),%eax
 293:	89 44 24 04          	mov    %eax,0x4(%esp)
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	89 04 24             	mov    %eax,(%esp)
 29d:	e8 22 ff ff ff       	call   1c4 <stosb>
  return dst;
 2a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2a5:	c9                   	leave  
 2a6:	c3                   	ret    

000002a7 <strchr>:

char*
strchr(const char *s, char c)
{
 2a7:	55                   	push   %ebp
 2a8:	89 e5                	mov    %esp,%ebp
 2aa:	83 ec 04             	sub    $0x4,%esp
 2ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b0:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2b3:	eb 14                	jmp    2c9 <strchr+0x22>
    if(*s == c)
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2be:	75 05                	jne    2c5 <strchr+0x1e>
      return (char*)s;
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
 2c3:	eb 13                	jmp    2d8 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c9:	8b 45 08             	mov    0x8(%ebp),%eax
 2cc:	0f b6 00             	movzbl (%eax),%eax
 2cf:	84 c0                	test   %al,%al
 2d1:	75 e2                	jne    2b5 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2d8:	c9                   	leave  
 2d9:	c3                   	ret    

000002da <gets>:

char*
gets(char *buf, int max)
{
 2da:	55                   	push   %ebp
 2db:	89 e5                	mov    %esp,%ebp
 2dd:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2e7:	eb 44                	jmp    32d <gets+0x53>
    cc = read(0, &c, 1);
 2e9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2f0:	00 
 2f1:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2f4:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 2ff:	e8 3c 01 00 00       	call   440 <read>
 304:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 307:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 30b:	7e 2d                	jle    33a <gets+0x60>
      break;
    buf[i++] = c;
 30d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 310:	03 45 08             	add    0x8(%ebp),%eax
 313:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 317:	88 10                	mov    %dl,(%eax)
 319:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 31d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 321:	3c 0a                	cmp    $0xa,%al
 323:	74 16                	je     33b <gets+0x61>
 325:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 329:	3c 0d                	cmp    $0xd,%al
 32b:	74 0e                	je     33b <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 32d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 330:	83 c0 01             	add    $0x1,%eax
 333:	3b 45 0c             	cmp    0xc(%ebp),%eax
 336:	7c b1                	jl     2e9 <gets+0xf>
 338:	eb 01                	jmp    33b <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 33a:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 33b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 33e:	03 45 08             	add    0x8(%ebp),%eax
 341:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 344:	8b 45 08             	mov    0x8(%ebp),%eax
}
 347:	c9                   	leave  
 348:	c3                   	ret    

00000349 <stat>:

int
stat(char *n, struct stat *st)
{
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
 34c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 34f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 356:	00 
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	89 04 24             	mov    %eax,(%esp)
 35d:	e8 06 01 00 00       	call   468 <open>
 362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 365:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 369:	79 07                	jns    372 <stat+0x29>
    return -1;
 36b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 370:	eb 23                	jmp    395 <stat+0x4c>
  r = fstat(fd, st);
 372:	8b 45 0c             	mov    0xc(%ebp),%eax
 375:	89 44 24 04          	mov    %eax,0x4(%esp)
 379:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37c:	89 04 24             	mov    %eax,(%esp)
 37f:	e8 fc 00 00 00       	call   480 <fstat>
 384:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 387:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38a:	89 04 24             	mov    %eax,(%esp)
 38d:	e8 be 00 00 00       	call   450 <close>
  return r;
 392:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 395:	c9                   	leave  
 396:	c3                   	ret    

00000397 <atoi>:

int
atoi(const char *s)
{
 397:	55                   	push   %ebp
 398:	89 e5                	mov    %esp,%ebp
 39a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 39d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3a4:	eb 23                	jmp    3c9 <atoi+0x32>
    n = n*10 + *s++ - '0';
 3a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3a9:	89 d0                	mov    %edx,%eax
 3ab:	c1 e0 02             	shl    $0x2,%eax
 3ae:	01 d0                	add    %edx,%eax
 3b0:	01 c0                	add    %eax,%eax
 3b2:	89 c2                	mov    %eax,%edx
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	0f b6 00             	movzbl (%eax),%eax
 3ba:	0f be c0             	movsbl %al,%eax
 3bd:	01 d0                	add    %edx,%eax
 3bf:	83 e8 30             	sub    $0x30,%eax
 3c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3c5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	0f b6 00             	movzbl (%eax),%eax
 3cf:	3c 2f                	cmp    $0x2f,%al
 3d1:	7e 0a                	jle    3dd <atoi+0x46>
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	0f b6 00             	movzbl (%eax),%eax
 3d9:	3c 39                	cmp    $0x39,%al
 3db:	7e c9                	jle    3a6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3e0:	c9                   	leave  
 3e1:	c3                   	ret    

000003e2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3e2:	55                   	push   %ebp
 3e3:	89 e5                	mov    %esp,%ebp
 3e5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3e8:	8b 45 08             	mov    0x8(%ebp),%eax
 3eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3f4:	eb 13                	jmp    409 <memmove+0x27>
    *dst++ = *src++;
 3f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3f9:	0f b6 10             	movzbl (%eax),%edx
 3fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3ff:	88 10                	mov    %dl,(%eax)
 401:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 405:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 409:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 40d:	0f 9f c0             	setg   %al
 410:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 414:	84 c0                	test   %al,%al
 416:	75 de                	jne    3f6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 418:	8b 45 08             	mov    0x8(%ebp),%eax
}
 41b:	c9                   	leave  
 41c:	c3                   	ret    
 41d:	90                   	nop
 41e:	90                   	nop
 41f:	90                   	nop

00000420 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 420:	b8 01 00 00 00       	mov    $0x1,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <exit>:
SYSCALL(exit)
 428:	b8 02 00 00 00       	mov    $0x2,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <wait>:
SYSCALL(wait)
 430:	b8 03 00 00 00       	mov    $0x3,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <pipe>:
SYSCALL(pipe)
 438:	b8 04 00 00 00       	mov    $0x4,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <read>:
SYSCALL(read)
 440:	b8 05 00 00 00       	mov    $0x5,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <write>:
SYSCALL(write)
 448:	b8 10 00 00 00       	mov    $0x10,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <close>:
SYSCALL(close)
 450:	b8 15 00 00 00       	mov    $0x15,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <kill>:
SYSCALL(kill)
 458:	b8 06 00 00 00       	mov    $0x6,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <exec>:
SYSCALL(exec)
 460:	b8 07 00 00 00       	mov    $0x7,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <open>:
SYSCALL(open)
 468:	b8 0f 00 00 00       	mov    $0xf,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <mknod>:
SYSCALL(mknod)
 470:	b8 11 00 00 00       	mov    $0x11,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <unlink>:
SYSCALL(unlink)
 478:	b8 12 00 00 00       	mov    $0x12,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <fstat>:
SYSCALL(fstat)
 480:	b8 08 00 00 00       	mov    $0x8,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <link>:
SYSCALL(link)
 488:	b8 13 00 00 00       	mov    $0x13,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <mkdir>:
SYSCALL(mkdir)
 490:	b8 14 00 00 00       	mov    $0x14,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <chdir>:
SYSCALL(chdir)
 498:	b8 09 00 00 00       	mov    $0x9,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <dup>:
SYSCALL(dup)
 4a0:	b8 0a 00 00 00       	mov    $0xa,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <getpid>:
SYSCALL(getpid)
 4a8:	b8 0b 00 00 00       	mov    $0xb,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <sbrk>:
SYSCALL(sbrk)
 4b0:	b8 0c 00 00 00       	mov    $0xc,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <sleep>:
SYSCALL(sleep)
 4b8:	b8 0d 00 00 00       	mov    $0xd,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <uptime>:
SYSCALL(uptime)
 4c0:	b8 0e 00 00 00       	mov    $0xe,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <thread_create>:
SYSCALL(thread_create)
 4c8:	b8 16 00 00 00       	mov    $0x16,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <thread_getId>:
SYSCALL(thread_getId)
 4d0:	b8 17 00 00 00       	mov    $0x17,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <thread_getProcId>:
SYSCALL(thread_getProcId)
 4d8:	b8 18 00 00 00       	mov    $0x18,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <thread_join>:
SYSCALL(thread_join)
 4e0:	b8 19 00 00 00       	mov    $0x19,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <thread_exit>:
SYSCALL(thread_exit)
 4e8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <binary_semaphore_create>:
SYSCALL(binary_semaphore_create)
 4f0:	b8 1b 00 00 00       	mov    $0x1b,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <binary_semaphore_down>:
SYSCALL(binary_semaphore_down)
 4f8:	b8 1c 00 00 00       	mov    $0x1c,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <binary_semaphore_up>:
SYSCALL(binary_semaphore_up)
 500:	b8 1d 00 00 00       	mov    $0x1d,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 508:	55                   	push   %ebp
 509:	89 e5                	mov    %esp,%ebp
 50b:	83 ec 28             	sub    $0x28,%esp
 50e:	8b 45 0c             	mov    0xc(%ebp),%eax
 511:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 514:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 51b:	00 
 51c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 51f:	89 44 24 04          	mov    %eax,0x4(%esp)
 523:	8b 45 08             	mov    0x8(%ebp),%eax
 526:	89 04 24             	mov    %eax,(%esp)
 529:	e8 1a ff ff ff       	call   448 <write>
}
 52e:	c9                   	leave  
 52f:	c3                   	ret    

00000530 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 530:	55                   	push   %ebp
 531:	89 e5                	mov    %esp,%ebp
 533:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 536:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 53d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 541:	74 17                	je     55a <printint+0x2a>
 543:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 547:	79 11                	jns    55a <printint+0x2a>
    neg = 1;
 549:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 550:	8b 45 0c             	mov    0xc(%ebp),%eax
 553:	f7 d8                	neg    %eax
 555:	89 45 ec             	mov    %eax,-0x14(%ebp)
 558:	eb 06                	jmp    560 <printint+0x30>
  } else {
    x = xx;
 55a:	8b 45 0c             	mov    0xc(%ebp),%eax
 55d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 560:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 567:	8b 4d 10             	mov    0x10(%ebp),%ecx
 56a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 56d:	ba 00 00 00 00       	mov    $0x0,%edx
 572:	f7 f1                	div    %ecx
 574:	89 d0                	mov    %edx,%eax
 576:	0f b6 90 c8 11 00 00 	movzbl 0x11c8(%eax),%edx
 57d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 580:	03 45 f4             	add    -0xc(%ebp),%eax
 583:	88 10                	mov    %dl,(%eax)
 585:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 589:	8b 55 10             	mov    0x10(%ebp),%edx
 58c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 58f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 592:	ba 00 00 00 00       	mov    $0x0,%edx
 597:	f7 75 d4             	divl   -0x2c(%ebp)
 59a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 59d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5a1:	75 c4                	jne    567 <printint+0x37>
  if(neg)
 5a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5a7:	74 2a                	je     5d3 <printint+0xa3>
    buf[i++] = '-';
 5a9:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5ac:	03 45 f4             	add    -0xc(%ebp),%eax
 5af:	c6 00 2d             	movb   $0x2d,(%eax)
 5b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 5b6:	eb 1b                	jmp    5d3 <printint+0xa3>
    putc(fd, buf[i]);
 5b8:	8d 45 dc             	lea    -0x24(%ebp),%eax
 5bb:	03 45 f4             	add    -0xc(%ebp),%eax
 5be:	0f b6 00             	movzbl (%eax),%eax
 5c1:	0f be c0             	movsbl %al,%eax
 5c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 5c8:	8b 45 08             	mov    0x8(%ebp),%eax
 5cb:	89 04 24             	mov    %eax,(%esp)
 5ce:	e8 35 ff ff ff       	call   508 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5d3:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5db:	79 db                	jns    5b8 <printint+0x88>
    putc(fd, buf[i]);
}
 5dd:	c9                   	leave  
 5de:	c3                   	ret    

000005df <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5df:	55                   	push   %ebp
 5e0:	89 e5                	mov    %esp,%ebp
 5e2:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5e5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5ec:	8d 45 0c             	lea    0xc(%ebp),%eax
 5ef:	83 c0 04             	add    $0x4,%eax
 5f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5f5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5fc:	e9 7d 01 00 00       	jmp    77e <printf+0x19f>
    c = fmt[i] & 0xff;
 601:	8b 55 0c             	mov    0xc(%ebp),%edx
 604:	8b 45 f0             	mov    -0x10(%ebp),%eax
 607:	01 d0                	add    %edx,%eax
 609:	0f b6 00             	movzbl (%eax),%eax
 60c:	0f be c0             	movsbl %al,%eax
 60f:	25 ff 00 00 00       	and    $0xff,%eax
 614:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 617:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 61b:	75 2c                	jne    649 <printf+0x6a>
      if(c == '%'){
 61d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 621:	75 0c                	jne    62f <printf+0x50>
        state = '%';
 623:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 62a:	e9 4b 01 00 00       	jmp    77a <printf+0x19b>
      } else {
        putc(fd, c);
 62f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 632:	0f be c0             	movsbl %al,%eax
 635:	89 44 24 04          	mov    %eax,0x4(%esp)
 639:	8b 45 08             	mov    0x8(%ebp),%eax
 63c:	89 04 24             	mov    %eax,(%esp)
 63f:	e8 c4 fe ff ff       	call   508 <putc>
 644:	e9 31 01 00 00       	jmp    77a <printf+0x19b>
      }
    } else if(state == '%'){
 649:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 64d:	0f 85 27 01 00 00    	jne    77a <printf+0x19b>
      if(c == 'd'){
 653:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 657:	75 2d                	jne    686 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 659:	8b 45 e8             	mov    -0x18(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 665:	00 
 666:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 66d:	00 
 66e:	89 44 24 04          	mov    %eax,0x4(%esp)
 672:	8b 45 08             	mov    0x8(%ebp),%eax
 675:	89 04 24             	mov    %eax,(%esp)
 678:	e8 b3 fe ff ff       	call   530 <printint>
        ap++;
 67d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 681:	e9 ed 00 00 00       	jmp    773 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 686:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 68a:	74 06                	je     692 <printf+0xb3>
 68c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 690:	75 2d                	jne    6bf <printf+0xe0>
        printint(fd, *ap, 16, 0);
 692:	8b 45 e8             	mov    -0x18(%ebp),%eax
 695:	8b 00                	mov    (%eax),%eax
 697:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 69e:	00 
 69f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6a6:	00 
 6a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
 6ae:	89 04 24             	mov    %eax,(%esp)
 6b1:	e8 7a fe ff ff       	call   530 <printint>
        ap++;
 6b6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ba:	e9 b4 00 00 00       	jmp    773 <printf+0x194>
      } else if(c == 's'){
 6bf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6c3:	75 46                	jne    70b <printf+0x12c>
        s = (char*)*ap;
 6c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6c8:	8b 00                	mov    (%eax),%eax
 6ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6cd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6d5:	75 27                	jne    6fe <printf+0x11f>
          s = "(null)";
 6d7:	c7 45 f4 c5 0d 00 00 	movl   $0xdc5,-0xc(%ebp)
        while(*s != 0){
 6de:	eb 1e                	jmp    6fe <printf+0x11f>
          putc(fd, *s);
 6e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e3:	0f b6 00             	movzbl (%eax),%eax
 6e6:	0f be c0             	movsbl %al,%eax
 6e9:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ed:	8b 45 08             	mov    0x8(%ebp),%eax
 6f0:	89 04 24             	mov    %eax,(%esp)
 6f3:	e8 10 fe ff ff       	call   508 <putc>
          s++;
 6f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 6fc:	eb 01                	jmp    6ff <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6fe:	90                   	nop
 6ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 702:	0f b6 00             	movzbl (%eax),%eax
 705:	84 c0                	test   %al,%al
 707:	75 d7                	jne    6e0 <printf+0x101>
 709:	eb 68                	jmp    773 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 70b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 70f:	75 1d                	jne    72e <printf+0x14f>
        putc(fd, *ap);
 711:	8b 45 e8             	mov    -0x18(%ebp),%eax
 714:	8b 00                	mov    (%eax),%eax
 716:	0f be c0             	movsbl %al,%eax
 719:	89 44 24 04          	mov    %eax,0x4(%esp)
 71d:	8b 45 08             	mov    0x8(%ebp),%eax
 720:	89 04 24             	mov    %eax,(%esp)
 723:	e8 e0 fd ff ff       	call   508 <putc>
        ap++;
 728:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 72c:	eb 45                	jmp    773 <printf+0x194>
      } else if(c == '%'){
 72e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 732:	75 17                	jne    74b <printf+0x16c>
        putc(fd, c);
 734:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 737:	0f be c0             	movsbl %al,%eax
 73a:	89 44 24 04          	mov    %eax,0x4(%esp)
 73e:	8b 45 08             	mov    0x8(%ebp),%eax
 741:	89 04 24             	mov    %eax,(%esp)
 744:	e8 bf fd ff ff       	call   508 <putc>
 749:	eb 28                	jmp    773 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 74b:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 752:	00 
 753:	8b 45 08             	mov    0x8(%ebp),%eax
 756:	89 04 24             	mov    %eax,(%esp)
 759:	e8 aa fd ff ff       	call   508 <putc>
        putc(fd, c);
 75e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 761:	0f be c0             	movsbl %al,%eax
 764:	89 44 24 04          	mov    %eax,0x4(%esp)
 768:	8b 45 08             	mov    0x8(%ebp),%eax
 76b:	89 04 24             	mov    %eax,(%esp)
 76e:	e8 95 fd ff ff       	call   508 <putc>
      }
      state = 0;
 773:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 77a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 77e:	8b 55 0c             	mov    0xc(%ebp),%edx
 781:	8b 45 f0             	mov    -0x10(%ebp),%eax
 784:	01 d0                	add    %edx,%eax
 786:	0f b6 00             	movzbl (%eax),%eax
 789:	84 c0                	test   %al,%al
 78b:	0f 85 70 fe ff ff    	jne    601 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 791:	c9                   	leave  
 792:	c3                   	ret    
 793:	90                   	nop

00000794 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 794:	55                   	push   %ebp
 795:	89 e5                	mov    %esp,%ebp
 797:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 79a:	8b 45 08             	mov    0x8(%ebp),%eax
 79d:	83 e8 08             	sub    $0x8,%eax
 7a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a3:	a1 e8 11 00 00       	mov    0x11e8,%eax
 7a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7ab:	eb 24                	jmp    7d1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b0:	8b 00                	mov    (%eax),%eax
 7b2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7b5:	77 12                	ja     7c9 <free+0x35>
 7b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ba:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7bd:	77 24                	ja     7e3 <free+0x4f>
 7bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c2:	8b 00                	mov    (%eax),%eax
 7c4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c7:	77 1a                	ja     7e3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7d7:	76 d4                	jbe    7ad <free+0x19>
 7d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dc:	8b 00                	mov    (%eax),%eax
 7de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7e1:	76 ca                	jbe    7ad <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e6:	8b 40 04             	mov    0x4(%eax),%eax
 7e9:	c1 e0 03             	shl    $0x3,%eax
 7ec:	89 c2                	mov    %eax,%edx
 7ee:	03 55 f8             	add    -0x8(%ebp),%edx
 7f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	39 c2                	cmp    %eax,%edx
 7f8:	75 24                	jne    81e <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 7fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7fd:	8b 50 04             	mov    0x4(%eax),%edx
 800:	8b 45 fc             	mov    -0x4(%ebp),%eax
 803:	8b 00                	mov    (%eax),%eax
 805:	8b 40 04             	mov    0x4(%eax),%eax
 808:	01 c2                	add    %eax,%edx
 80a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 810:	8b 45 fc             	mov    -0x4(%ebp),%eax
 813:	8b 00                	mov    (%eax),%eax
 815:	8b 10                	mov    (%eax),%edx
 817:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81a:	89 10                	mov    %edx,(%eax)
 81c:	eb 0a                	jmp    828 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 81e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 821:	8b 10                	mov    (%eax),%edx
 823:	8b 45 f8             	mov    -0x8(%ebp),%eax
 826:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	8b 40 04             	mov    0x4(%eax),%eax
 82e:	c1 e0 03             	shl    $0x3,%eax
 831:	03 45 fc             	add    -0x4(%ebp),%eax
 834:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 837:	75 20                	jne    859 <free+0xc5>
    p->s.size += bp->s.size;
 839:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83c:	8b 50 04             	mov    0x4(%eax),%edx
 83f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 842:	8b 40 04             	mov    0x4(%eax),%eax
 845:	01 c2                	add    %eax,%edx
 847:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 84d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 850:	8b 10                	mov    (%eax),%edx
 852:	8b 45 fc             	mov    -0x4(%ebp),%eax
 855:	89 10                	mov    %edx,(%eax)
 857:	eb 08                	jmp    861 <free+0xcd>
  } else
    p->s.ptr = bp;
 859:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 85f:	89 10                	mov    %edx,(%eax)
  freep = p;
 861:	8b 45 fc             	mov    -0x4(%ebp),%eax
 864:	a3 e8 11 00 00       	mov    %eax,0x11e8
}
 869:	c9                   	leave  
 86a:	c3                   	ret    

0000086b <morecore>:

static Header*
morecore(uint nu)
{
 86b:	55                   	push   %ebp
 86c:	89 e5                	mov    %esp,%ebp
 86e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 871:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 878:	77 07                	ja     881 <morecore+0x16>
    nu = 4096;
 87a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 881:	8b 45 08             	mov    0x8(%ebp),%eax
 884:	c1 e0 03             	shl    $0x3,%eax
 887:	89 04 24             	mov    %eax,(%esp)
 88a:	e8 21 fc ff ff       	call   4b0 <sbrk>
 88f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 892:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 896:	75 07                	jne    89f <morecore+0x34>
    return 0;
 898:	b8 00 00 00 00       	mov    $0x0,%eax
 89d:	eb 22                	jmp    8c1 <morecore+0x56>
  hp = (Header*)p;
 89f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a8:	8b 55 08             	mov    0x8(%ebp),%edx
 8ab:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b1:	83 c0 08             	add    $0x8,%eax
 8b4:	89 04 24             	mov    %eax,(%esp)
 8b7:	e8 d8 fe ff ff       	call   794 <free>
  return freep;
 8bc:	a1 e8 11 00 00       	mov    0x11e8,%eax
}
 8c1:	c9                   	leave  
 8c2:	c3                   	ret    

000008c3 <malloc>:

void*
malloc(uint nbytes)
{
 8c3:	55                   	push   %ebp
 8c4:	89 e5                	mov    %esp,%ebp
 8c6:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c9:	8b 45 08             	mov    0x8(%ebp),%eax
 8cc:	83 c0 07             	add    $0x7,%eax
 8cf:	c1 e8 03             	shr    $0x3,%eax
 8d2:	83 c0 01             	add    $0x1,%eax
 8d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8d8:	a1 e8 11 00 00       	mov    0x11e8,%eax
 8dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8e4:	75 23                	jne    909 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8e6:	c7 45 f0 e0 11 00 00 	movl   $0x11e0,-0x10(%ebp)
 8ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f0:	a3 e8 11 00 00       	mov    %eax,0x11e8
 8f5:	a1 e8 11 00 00       	mov    0x11e8,%eax
 8fa:	a3 e0 11 00 00       	mov    %eax,0x11e0
    base.s.size = 0;
 8ff:	c7 05 e4 11 00 00 00 	movl   $0x0,0x11e4
 906:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 909:	8b 45 f0             	mov    -0x10(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 911:	8b 45 f4             	mov    -0xc(%ebp),%eax
 914:	8b 40 04             	mov    0x4(%eax),%eax
 917:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 91a:	72 4d                	jb     969 <malloc+0xa6>
      if(p->s.size == nunits)
 91c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91f:	8b 40 04             	mov    0x4(%eax),%eax
 922:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 925:	75 0c                	jne    933 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 927:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92a:	8b 10                	mov    (%eax),%edx
 92c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 92f:	89 10                	mov    %edx,(%eax)
 931:	eb 26                	jmp    959 <malloc+0x96>
      else {
        p->s.size -= nunits;
 933:	8b 45 f4             	mov    -0xc(%ebp),%eax
 936:	8b 40 04             	mov    0x4(%eax),%eax
 939:	89 c2                	mov    %eax,%edx
 93b:	2b 55 ec             	sub    -0x14(%ebp),%edx
 93e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 941:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 944:	8b 45 f4             	mov    -0xc(%ebp),%eax
 947:	8b 40 04             	mov    0x4(%eax),%eax
 94a:	c1 e0 03             	shl    $0x3,%eax
 94d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 950:	8b 45 f4             	mov    -0xc(%ebp),%eax
 953:	8b 55 ec             	mov    -0x14(%ebp),%edx
 956:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 959:	8b 45 f0             	mov    -0x10(%ebp),%eax
 95c:	a3 e8 11 00 00       	mov    %eax,0x11e8
      return (void*)(p + 1);
 961:	8b 45 f4             	mov    -0xc(%ebp),%eax
 964:	83 c0 08             	add    $0x8,%eax
 967:	eb 38                	jmp    9a1 <malloc+0xde>
    }
    if(p == freep)
 969:	a1 e8 11 00 00       	mov    0x11e8,%eax
 96e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 971:	75 1b                	jne    98e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 973:	8b 45 ec             	mov    -0x14(%ebp),%eax
 976:	89 04 24             	mov    %eax,(%esp)
 979:	e8 ed fe ff ff       	call   86b <morecore>
 97e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 985:	75 07                	jne    98e <malloc+0xcb>
        return 0;
 987:	b8 00 00 00 00       	mov    $0x0,%eax
 98c:	eb 13                	jmp    9a1 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 991:	89 45 f0             	mov    %eax,-0x10(%ebp)
 994:	8b 45 f4             	mov    -0xc(%ebp),%eax
 997:	8b 00                	mov    (%eax),%eax
 999:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 99c:	e9 70 ff ff ff       	jmp    911 <malloc+0x4e>
}
 9a1:	c9                   	leave  
 9a2:	c3                   	ret    
 9a3:	90                   	nop

000009a4 <semaphore_create>:
#include "semaphore.h"
#include "types.h"
#include "user.h"


struct semaphore* semaphore_create(int initial_semaphore_value){
 9a4:	55                   	push   %ebp
 9a5:	89 e5                	mov    %esp,%ebp
 9a7:	83 ec 28             	sub    $0x28,%esp
  struct semaphore* sem=malloc(sizeof(struct semaphore)); 
 9aa:	c7 04 24 10 00 00 00 	movl   $0x10,(%esp)
 9b1:	e8 0d ff ff ff       	call   8c3 <malloc>
 9b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // acquire semaphors
  sem->s1 = binary_semaphore_create(1);
 9b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 9c0:	e8 2b fb ff ff       	call   4f0 <binary_semaphore_create>
 9c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
 9c8:	89 02                	mov    %eax,(%edx)
  
  // s2 should be initialized with the min{1,initial_semaphore_value}
  if(initial_semaphore_value >= 1){
 9ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 9ce:	7e 14                	jle    9e4 <semaphore_create+0x40>
    sem->s2 = binary_semaphore_create(1);
 9d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 9d7:	e8 14 fb ff ff       	call   4f0 <binary_semaphore_create>
 9dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
 9df:	89 42 04             	mov    %eax,0x4(%edx)
 9e2:	eb 11                	jmp    9f5 <semaphore_create+0x51>
  }else{
    sem->s2 = binary_semaphore_create(initial_semaphore_value);
 9e4:	8b 45 08             	mov    0x8(%ebp),%eax
 9e7:	89 04 24             	mov    %eax,(%esp)
 9ea:	e8 01 fb ff ff       	call   4f0 <binary_semaphore_create>
 9ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
 9f2:	89 42 04             	mov    %eax,0x4(%edx)
  }
  
  if(sem->s1 == -1 || sem->s2 == -1){
 9f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f8:	8b 00                	mov    (%eax),%eax
 9fa:	83 f8 ff             	cmp    $0xffffffff,%eax
 9fd:	74 0b                	je     a0a <semaphore_create+0x66>
 9ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a02:	8b 40 04             	mov    0x4(%eax),%eax
 a05:	83 f8 ff             	cmp    $0xffffffff,%eax
 a08:	75 26                	jne    a30 <semaphore_create+0x8c>
     printf(1,"we had a probalem initialize in semaphore_create\n");
 a0a:	c7 44 24 04 cc 0d 00 	movl   $0xdcc,0x4(%esp)
 a11:	00 
 a12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 a19:	e8 c1 fb ff ff       	call   5df <printf>
     free(sem);
 a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a21:	89 04 24             	mov    %eax,(%esp)
 a24:	e8 6b fd ff ff       	call   794 <free>
     return 0;
 a29:	b8 00 00 00 00       	mov    $0x0,%eax
 a2e:	eb 15                	jmp    a45 <semaphore_create+0xa1>
  }
  //initialize value
  sem->value = initial_semaphore_value;//dynamic
 a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a33:	8b 55 08             	mov    0x8(%ebp),%edx
 a36:	89 50 08             	mov    %edx,0x8(%eax)
  sem->initial_value = initial_semaphore_value;//static
 a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a3c:	8b 55 08             	mov    0x8(%ebp),%edx
 a3f:	89 50 0c             	mov    %edx,0xc(%eax)
  
  return sem;
 a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 a45:	c9                   	leave  
 a46:	c3                   	ret    

00000a47 <semaphore_down>:
void semaphore_down(struct semaphore* sem ){
 a47:	55                   	push   %ebp
 a48:	89 e5                	mov    %esp,%ebp
 a4a:	83 ec 18             	sub    $0x18,%esp
  binary_semaphore_down(sem->s2);
 a4d:	8b 45 08             	mov    0x8(%ebp),%eax
 a50:	8b 40 04             	mov    0x4(%eax),%eax
 a53:	89 04 24             	mov    %eax,(%esp)
 a56:	e8 9d fa ff ff       	call   4f8 <binary_semaphore_down>
  binary_semaphore_down(sem->s1);
 a5b:	8b 45 08             	mov    0x8(%ebp),%eax
 a5e:	8b 00                	mov    (%eax),%eax
 a60:	89 04 24             	mov    %eax,(%esp)
 a63:	e8 90 fa ff ff       	call   4f8 <binary_semaphore_down>
  sem->value--;	
 a68:	8b 45 08             	mov    0x8(%ebp),%eax
 a6b:	8b 40 08             	mov    0x8(%eax),%eax
 a6e:	8d 50 ff             	lea    -0x1(%eax),%edx
 a71:	8b 45 08             	mov    0x8(%ebp),%eax
 a74:	89 50 08             	mov    %edx,0x8(%eax)
  if(sem->value > 0){
 a77:	8b 45 08             	mov    0x8(%ebp),%eax
 a7a:	8b 40 08             	mov    0x8(%eax),%eax
 a7d:	85 c0                	test   %eax,%eax
 a7f:	7e 0e                	jle    a8f <semaphore_down+0x48>
   binary_semaphore_up(sem->s2);
 a81:	8b 45 08             	mov    0x8(%ebp),%eax
 a84:	8b 40 04             	mov    0x4(%eax),%eax
 a87:	89 04 24             	mov    %eax,(%esp)
 a8a:	e8 71 fa ff ff       	call   500 <binary_semaphore_up>
  }
  binary_semaphore_up(sem->s1); 
 a8f:	8b 45 08             	mov    0x8(%ebp),%eax
 a92:	8b 00                	mov    (%eax),%eax
 a94:	89 04 24             	mov    %eax,(%esp)
 a97:	e8 64 fa ff ff       	call   500 <binary_semaphore_up>
}
 a9c:	c9                   	leave  
 a9d:	c3                   	ret    

00000a9e <semaphore_up>:
void semaphore_up(struct semaphore* sem ){
 a9e:	55                   	push   %ebp
 a9f:	89 e5                	mov    %esp,%ebp
 aa1:	83 ec 18             	sub    $0x18,%esp
  binary_semaphore_down(sem->s1);
 aa4:	8b 45 08             	mov    0x8(%ebp),%eax
 aa7:	8b 00                	mov    (%eax),%eax
 aa9:	89 04 24             	mov    %eax,(%esp)
 aac:	e8 47 fa ff ff       	call   4f8 <binary_semaphore_down>
  sem->value++;	
 ab1:	8b 45 08             	mov    0x8(%ebp),%eax
 ab4:	8b 40 08             	mov    0x8(%eax),%eax
 ab7:	8d 50 01             	lea    0x1(%eax),%edx
 aba:	8b 45 08             	mov    0x8(%ebp),%eax
 abd:	89 50 08             	mov    %edx,0x8(%eax)
  if(sem->value ==1){
 ac0:	8b 45 08             	mov    0x8(%ebp),%eax
 ac3:	8b 40 08             	mov    0x8(%eax),%eax
 ac6:	83 f8 01             	cmp    $0x1,%eax
 ac9:	75 0e                	jne    ad9 <semaphore_up+0x3b>
   binary_semaphore_up(sem->s2); 
 acb:	8b 45 08             	mov    0x8(%ebp),%eax
 ace:	8b 40 04             	mov    0x4(%eax),%eax
 ad1:	89 04 24             	mov    %eax,(%esp)
 ad4:	e8 27 fa ff ff       	call   500 <binary_semaphore_up>
   }
  binary_semaphore_up(sem->s1);
 ad9:	8b 45 08             	mov    0x8(%ebp),%eax
 adc:	8b 00                	mov    (%eax),%eax
 ade:	89 04 24             	mov    %eax,(%esp)
 ae1:	e8 1a fa ff ff       	call   500 <binary_semaphore_up>
}
 ae6:	c9                   	leave  
 ae7:	c3                   	ret    

00000ae8 <semaphore_free>:

void semaphore_free(struct semaphore* sem){
 ae8:	55                   	push   %ebp
 ae9:	89 e5                	mov    %esp,%ebp
 aeb:	83 ec 18             	sub    $0x18,%esp
  free(sem);
 aee:	8b 45 08             	mov    0x8(%ebp),%eax
 af1:	89 04 24             	mov    %eax,(%esp)
 af4:	e8 9b fc ff ff       	call   794 <free>
}
 af9:	c9                   	leave  
 afa:	c3                   	ret    
 afb:	90                   	nop

00000afc <BB_create>:
#include "types.h"
#include "user.h"


struct BB* 
BB_create(int max_capacity){
 afc:	55                   	push   %ebp
 afd:	89 e5                	mov    %esp,%ebp
 aff:	83 ec 38             	sub    $0x38,%esp
  //initialize
  struct BB* buf = malloc(sizeof(struct BB));
 b02:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
 b09:	e8 b5 fd ff ff       	call   8c3 <malloc>
 b0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(buf,0,sizeof(struct BB));
 b11:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
 b18:	00 
 b19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 b20:	00 
 b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b24:	89 04 24             	mov    %eax,(%esp)
 b27:	e8 57 f7 ff ff       	call   283 <memset>
 
  buf->buffer_size = max_capacity;
 b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2f:	8b 55 08             	mov    0x8(%ebp),%edx
 b32:	89 10                	mov    %edx,(%eax)
  buf->mutex = binary_semaphore_create(1);  
 b34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 b3b:	e8 b0 f9 ff ff       	call   4f0 <binary_semaphore_create>
 b40:	8b 55 f4             	mov    -0xc(%ebp),%edx
 b43:	89 42 04             	mov    %eax,0x4(%edx)
  buf->empty = semaphore_create(max_capacity);
 b46:	8b 45 08             	mov    0x8(%ebp),%eax
 b49:	89 04 24             	mov    %eax,(%esp)
 b4c:	e8 53 fe ff ff       	call   9a4 <semaphore_create>
 b51:	8b 55 f4             	mov    -0xc(%ebp),%edx
 b54:	89 42 08             	mov    %eax,0x8(%edx)
  buf->full = semaphore_create(0);
 b57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 b5e:	e8 41 fe ff ff       	call   9a4 <semaphore_create>
 b63:	8b 55 f4             	mov    -0xc(%ebp),%edx
 b66:	89 42 0c             	mov    %eax,0xc(%edx)
  buf->pointer_to_elements = malloc(sizeof(void*)*max_capacity);
 b69:	8b 45 08             	mov    0x8(%ebp),%eax
 b6c:	c1 e0 02             	shl    $0x2,%eax
 b6f:	89 04 24             	mov    %eax,(%esp)
 b72:	e8 4c fd ff ff       	call   8c3 <malloc>
 b77:	8b 55 f4             	mov    -0xc(%ebp),%edx
 b7a:	89 42 1c             	mov    %eax,0x1c(%edx)
  memset(buf->pointer_to_elements,0,sizeof(void*)*max_capacity);
 b7d:	8b 45 08             	mov    0x8(%ebp),%eax
 b80:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b8a:	8b 40 1c             	mov    0x1c(%eax),%eax
 b8d:	89 54 24 08          	mov    %edx,0x8(%esp)
 b91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 b98:	00 
 b99:	89 04 24             	mov    %eax,(%esp)
 b9c:	e8 e2 f6 ff ff       	call   283 <memset>
  buf->count = 0;
 ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba4:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
  //check the semaphorses
  if(buf->mutex == -1 || buf->empty == 0 || buf->full == 0){
 bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bae:	8b 40 04             	mov    0x4(%eax),%eax
 bb1:	83 f8 ff             	cmp    $0xffffffff,%eax
 bb4:	74 14                	je     bca <BB_create+0xce>
 bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bb9:	8b 40 08             	mov    0x8(%eax),%eax
 bbc:	85 c0                	test   %eax,%eax
 bbe:	74 0a                	je     bca <BB_create+0xce>
 bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc3:	8b 40 0c             	mov    0xc(%eax),%eax
 bc6:	85 c0                	test   %eax,%eax
 bc8:	75 44                	jne    c0e <BB_create+0x112>
   printf(1,"we had a problam getting semaphores at BB create mutex %d empty %d full %d\n",buf->mutex,buf->empty,buf->full);
 bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bcd:	8b 48 0c             	mov    0xc(%eax),%ecx
 bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd3:	8b 50 08             	mov    0x8(%eax),%edx
 bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd9:	8b 40 04             	mov    0x4(%eax),%eax
 bdc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 be0:	89 54 24 0c          	mov    %edx,0xc(%esp)
 be4:	89 44 24 08          	mov    %eax,0x8(%esp)
 be8:	c7 44 24 04 00 0e 00 	movl   $0xe00,0x4(%esp)
 bef:	00 
 bf0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 bf7:	e8 e3 f9 ff ff       	call   5df <printf>
   BB_free(buf);
 bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bff:	89 04 24             	mov    %eax,(%esp)
 c02:	e8 47 01 00 00       	call   d4e <BB_free>
   
   buf =0;  
 c07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  }
  return buf;
 c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 c11:	c9                   	leave  
 c12:	c3                   	ret    

00000c13 <BB_put>:

void BB_put(struct BB* bb, void* element)
{ 
 c13:	55                   	push   %ebp
 c14:	89 e5                	mov    %esp,%ebp
 c16:	83 ec 18             	sub    $0x18,%esp
  semaphore_down(bb->empty);
 c19:	8b 45 08             	mov    0x8(%ebp),%eax
 c1c:	8b 40 08             	mov    0x8(%eax),%eax
 c1f:	89 04 24             	mov    %eax,(%esp)
 c22:	e8 20 fe ff ff       	call   a47 <semaphore_down>
  binary_semaphore_down(bb->mutex);
 c27:	8b 45 08             	mov    0x8(%ebp),%eax
 c2a:	8b 40 04             	mov    0x4(%eax),%eax
 c2d:	89 04 24             	mov    %eax,(%esp)
 c30:	e8 c3 f8 ff ff       	call   4f8 <binary_semaphore_down>
   //insert item
  bb->pointer_to_elements[bb->count] = element;
 c35:	8b 45 08             	mov    0x8(%ebp),%eax
 c38:	8b 50 1c             	mov    0x1c(%eax),%edx
 c3b:	8b 45 08             	mov    0x8(%ebp),%eax
 c3e:	8b 40 10             	mov    0x10(%eax),%eax
 c41:	c1 e0 02             	shl    $0x2,%eax
 c44:	01 c2                	add    %eax,%edx
 c46:	8b 45 0c             	mov    0xc(%ebp),%eax
 c49:	89 02                	mov    %eax,(%edx)
  bb->count++;
 c4b:	8b 45 08             	mov    0x8(%ebp),%eax
 c4e:	8b 40 10             	mov    0x10(%eax),%eax
 c51:	8d 50 01             	lea    0x1(%eax),%edx
 c54:	8b 45 08             	mov    0x8(%ebp),%eax
 c57:	89 50 10             	mov    %edx,0x10(%eax)
  binary_semaphore_up(bb->mutex);
 c5a:	8b 45 08             	mov    0x8(%ebp),%eax
 c5d:	8b 40 04             	mov    0x4(%eax),%eax
 c60:	89 04 24             	mov    %eax,(%esp)
 c63:	e8 98 f8 ff ff       	call   500 <binary_semaphore_up>
  semaphore_up(bb->full);
 c68:	8b 45 08             	mov    0x8(%ebp),%eax
 c6b:	8b 40 0c             	mov    0xc(%eax),%eax
 c6e:	89 04 24             	mov    %eax,(%esp)
 c71:	e8 28 fe ff ff       	call   a9e <semaphore_up>
}
 c76:	c9                   	leave  
 c77:	c3                   	ret    

00000c78 <BB_pop>:

void* BB_pop(struct BB* bb)
{
 c78:	55                   	push   %ebp
 c79:	89 e5                	mov    %esp,%ebp
 c7b:	83 ec 28             	sub    $0x28,%esp
  
  void* element_to_pop;
  semaphore_down(bb->full);
 c7e:	8b 45 08             	mov    0x8(%ebp),%eax
 c81:	8b 40 0c             	mov    0xc(%eax),%eax
 c84:	89 04 24             	mov    %eax,(%esp)
 c87:	e8 bb fd ff ff       	call   a47 <semaphore_down>
  binary_semaphore_down(bb->mutex);
 c8c:	8b 45 08             	mov    0x8(%ebp),%eax
 c8f:	8b 40 04             	mov    0x4(%eax),%eax
 c92:	89 04 24             	mov    %eax,(%esp)
 c95:	e8 5e f8 ff ff       	call   4f8 <binary_semaphore_down>
  element_to_pop = bb->pointer_to_elements[0];
 c9a:	8b 45 08             	mov    0x8(%ebp),%eax
 c9d:	8b 40 1c             	mov    0x1c(%eax),%eax
 ca0:	8b 00                	mov    (%eax),%eax
 ca2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  if(!element_to_pop){
 ca5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ca9:	75 14                	jne    cbf <BB_pop+0x47>
  printf(1,"we have uninitialize element\n");
 cab:	c7 44 24 04 4c 0e 00 	movl   $0xe4c,0x4(%esp)
 cb2:	00 
 cb3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 cba:	e8 20 f9 ff ff       	call   5df <printf>
  }
  
  // shift left all elements at the array
  int i;
  for(i = 0; i < bb->count ; i++){
 cbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 cc6:	eb 4b                	jmp    d13 <BB_pop+0x9b>
    if(i != (bb->count -1)){
 cc8:	8b 45 08             	mov    0x8(%ebp),%eax
 ccb:	8b 40 10             	mov    0x10(%eax),%eax
 cce:	83 e8 01             	sub    $0x1,%eax
 cd1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 cd4:	74 25                	je     cfb <BB_pop+0x83>
      bb->pointer_to_elements[i] = bb->pointer_to_elements[i+1];
 cd6:	8b 45 08             	mov    0x8(%ebp),%eax
 cd9:	8b 40 1c             	mov    0x1c(%eax),%eax
 cdc:	8b 55 f4             	mov    -0xc(%ebp),%edx
 cdf:	c1 e2 02             	shl    $0x2,%edx
 ce2:	01 c2                	add    %eax,%edx
 ce4:	8b 45 08             	mov    0x8(%ebp),%eax
 ce7:	8b 40 1c             	mov    0x1c(%eax),%eax
 cea:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 ced:	83 c1 01             	add    $0x1,%ecx
 cf0:	c1 e1 02             	shl    $0x2,%ecx
 cf3:	01 c8                	add    %ecx,%eax
 cf5:	8b 00                	mov    (%eax),%eax
 cf7:	89 02                	mov    %eax,(%edx)
 cf9:	eb 14                	jmp    d0f <BB_pop+0x97>
    }else{
      bb->pointer_to_elements[i] = 0;
 cfb:	8b 45 08             	mov    0x8(%ebp),%eax
 cfe:	8b 40 1c             	mov    0x1c(%eax),%eax
 d01:	8b 55 f4             	mov    -0xc(%ebp),%edx
 d04:	c1 e2 02             	shl    $0x2,%edx
 d07:	01 d0                	add    %edx,%eax
 d09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  printf(1,"we have uninitialize element\n");
  }
  
  // shift left all elements at the array
  int i;
  for(i = 0; i < bb->count ; i++){
 d0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 d13:	8b 45 08             	mov    0x8(%ebp),%eax
 d16:	8b 40 10             	mov    0x10(%eax),%eax
 d19:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 d1c:	7f aa                	jg     cc8 <BB_pop+0x50>
     }
     
  }
  
  
  bb->count--;
 d1e:	8b 45 08             	mov    0x8(%ebp),%eax
 d21:	8b 40 10             	mov    0x10(%eax),%eax
 d24:	8d 50 ff             	lea    -0x1(%eax),%edx
 d27:	8b 45 08             	mov    0x8(%ebp),%eax
 d2a:	89 50 10             	mov    %edx,0x10(%eax)
  
  binary_semaphore_up(bb->mutex);
 d2d:	8b 45 08             	mov    0x8(%ebp),%eax
 d30:	8b 40 04             	mov    0x4(%eax),%eax
 d33:	89 04 24             	mov    %eax,(%esp)
 d36:	e8 c5 f7 ff ff       	call   500 <binary_semaphore_up>
  semaphore_up(bb->empty);
 d3b:	8b 45 08             	mov    0x8(%ebp),%eax
 d3e:	8b 40 08             	mov    0x8(%eax),%eax
 d41:	89 04 24             	mov    %eax,(%esp)
 d44:	e8 55 fd ff ff       	call   a9e <semaphore_up>
  
  return element_to_pop;
 d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 d4c:	c9                   	leave  
 d4d:	c3                   	ret    

00000d4e <BB_free>:

void BB_free(struct BB* bb){
 d4e:	55                   	push   %ebp
 d4f:	89 e5                	mov    %esp,%ebp
 d51:	83 ec 18             	sub    $0x18,%esp
  semaphore_free(bb->empty);
 d54:	8b 45 08             	mov    0x8(%ebp),%eax
 d57:	8b 40 08             	mov    0x8(%eax),%eax
 d5a:	89 04 24             	mov    %eax,(%esp)
 d5d:	e8 86 fd ff ff       	call   ae8 <semaphore_free>
  semaphore_free(bb->full);
 d62:	8b 45 08             	mov    0x8(%ebp),%eax
 d65:	8b 40 0c             	mov    0xc(%eax),%eax
 d68:	89 04 24             	mov    %eax,(%esp)
 d6b:	e8 78 fd ff ff       	call   ae8 <semaphore_free>
  free(bb->pointer_to_elements);
 d70:	8b 45 08             	mov    0x8(%ebp),%eax
 d73:	8b 40 1c             	mov    0x1c(%eax),%eax
 d76:	89 04 24             	mov    %eax,(%esp)
 d79:	e8 16 fa ff ff       	call   794 <free>
  free(bb);
 d7e:	8b 45 08             	mov    0x8(%ebp),%eax
 d81:	89 04 24             	mov    %eax,(%esp)
 d84:	e8 0b fa ff ff       	call   794 <free>
}
 d89:	c9                   	leave  
 d8a:	c3                   	ret    
