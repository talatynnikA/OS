
_kill:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char **argv)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 1){
   9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   d:	7f 19                	jg     28 <main+0x28>
    printf(2, "usage: kill pid...\n");
   f:	c7 44 24 04 2c 0c 00 	movl   $0xc2c,0x4(%esp)
  16:	00 
  17:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1e:	e8 5c 04 00 00       	call   47f <printf>
    exit();
  23:	e8 a0 02 00 00       	call   2c8 <exit>
  }
  for(i=1; i<argc; i++)
  28:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
  2f:	00 
  30:	eb 21                	jmp    53 <main+0x53>
    kill(atoi(argv[i]));
  32:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  36:	c1 e0 02             	shl    $0x2,%eax
  39:	03 45 0c             	add    0xc(%ebp),%eax
  3c:	8b 00                	mov    (%eax),%eax
  3e:	89 04 24             	mov    %eax,(%esp)
  41:	e8 f1 01 00 00       	call   237 <atoi>
  46:	89 04 24             	mov    %eax,(%esp)
  49:	e8 aa 02 00 00       	call   2f8 <kill>

  if(argc < 1){
    printf(2, "usage: kill pid...\n");
    exit();
  }
  for(i=1; i<argc; i++)
  4e:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
  53:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  57:	3b 45 08             	cmp    0x8(%ebp),%eax
  5a:	7c d6                	jl     32 <main+0x32>
    kill(atoi(argv[i]));
  exit();
  5c:	e8 67 02 00 00       	call   2c8 <exit>
  61:	90                   	nop
  62:	90                   	nop
  63:	90                   	nop

00000064 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  64:	55                   	push   %ebp
  65:	89 e5                	mov    %esp,%ebp
  67:	57                   	push   %edi
  68:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  6c:	8b 55 10             	mov    0x10(%ebp),%edx
  6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  72:	89 cb                	mov    %ecx,%ebx
  74:	89 df                	mov    %ebx,%edi
  76:	89 d1                	mov    %edx,%ecx
  78:	fc                   	cld    
  79:	f3 aa                	rep stos %al,%es:(%edi)
  7b:	89 ca                	mov    %ecx,%edx
  7d:	89 fb                	mov    %edi,%ebx
  7f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  82:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  85:	5b                   	pop    %ebx
  86:	5f                   	pop    %edi
  87:	5d                   	pop    %ebp
  88:	c3                   	ret    

00000089 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  89:	55                   	push   %ebp
  8a:	89 e5                	mov    %esp,%ebp
  8c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  8f:	8b 45 08             	mov    0x8(%ebp),%eax
  92:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  95:	90                   	nop
  96:	8b 45 0c             	mov    0xc(%ebp),%eax
  99:	0f b6 10             	movzbl (%eax),%edx
  9c:	8b 45 08             	mov    0x8(%ebp),%eax
  9f:	88 10                	mov    %dl,(%eax)
  a1:	8b 45 08             	mov    0x8(%ebp),%eax
  a4:	0f b6 00             	movzbl (%eax),%eax
  a7:	84 c0                	test   %al,%al
  a9:	0f 95 c0             	setne  %al
  ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  b0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  b4:	84 c0                	test   %al,%al
  b6:	75 de                	jne    96 <strcpy+0xd>
    ;
  return os;
  b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  bb:	c9                   	leave  
  bc:	c3                   	ret    

000000bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  bd:	55                   	push   %ebp
  be:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  c0:	eb 08                	jmp    ca <strcmp+0xd>
    p++, q++;
  c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ca:	8b 45 08             	mov    0x8(%ebp),%eax
  cd:	0f b6 00             	movzbl (%eax),%eax
  d0:	84 c0                	test   %al,%al
  d2:	74 10                	je     e4 <strcmp+0x27>
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	0f b6 10             	movzbl (%eax),%edx
  da:	8b 45 0c             	mov    0xc(%ebp),%eax
  dd:	0f b6 00             	movzbl (%eax),%eax
  e0:	38 c2                	cmp    %al,%dl
  e2:	74 de                	je     c2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  e4:	8b 45 08             	mov    0x8(%ebp),%eax
  e7:	0f b6 00             	movzbl (%eax),%eax
  ea:	0f b6 d0             	movzbl %al,%edx
  ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  f0:	0f b6 00             	movzbl (%eax),%eax
  f3:	0f b6 c0             	movzbl %al,%eax
  f6:	89 d1                	mov    %edx,%ecx
  f8:	29 c1                	sub    %eax,%ecx
  fa:	89 c8                	mov    %ecx,%eax
}
  fc:	5d                   	pop    %ebp
  fd:	c3                   	ret    

000000fe <strlen>:

uint
strlen(char *s)
{
  fe:	55                   	push   %ebp
  ff:	89 e5                	mov    %esp,%ebp
 101:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 104:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 10b:	eb 04                	jmp    111 <strlen+0x13>
 10d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 111:	8b 45 fc             	mov    -0x4(%ebp),%eax
 114:	03 45 08             	add    0x8(%ebp),%eax
 117:	0f b6 00             	movzbl (%eax),%eax
 11a:	84 c0                	test   %al,%al
 11c:	75 ef                	jne    10d <strlen+0xf>
    ;
  return n;
 11e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 121:	c9                   	leave  
 122:	c3                   	ret    

00000123 <memset>:

void*
memset(void *dst, int c, uint n)
{
 123:	55                   	push   %ebp
 124:	89 e5                	mov    %esp,%ebp
 126:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 129:	8b 45 10             	mov    0x10(%ebp),%eax
 12c:	89 44 24 08          	mov    %eax,0x8(%esp)
 130:	8b 45 0c             	mov    0xc(%ebp),%eax
 133:	89 44 24 04          	mov    %eax,0x4(%esp)
 137:	8b 45 08             	mov    0x8(%ebp),%eax
 13a:	89 04 24             	mov    %eax,(%esp)
 13d:	e8 22 ff ff ff       	call   64 <stosb>
  return dst;
 142:	8b 45 08             	mov    0x8(%ebp),%eax
}
 145:	c9                   	leave  
 146:	c3                   	ret    

00000147 <strchr>:

char*
strchr(const char *s, char c)
{
 147:	55                   	push   %ebp
 148:	89 e5                	mov    %esp,%ebp
 14a:	83 ec 04             	sub    $0x4,%esp
 14d:	8b 45 0c             	mov    0xc(%ebp),%eax
 150:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 153:	eb 14                	jmp    169 <strchr+0x22>
    if(*s == c)
 155:	8b 45 08             	mov    0x8(%ebp),%eax
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 15e:	75 05                	jne    165 <strchr+0x1e>
      return (char*)s;
 160:	8b 45 08             	mov    0x8(%ebp),%eax
 163:	eb 13                	jmp    178 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 165:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 169:	8b 45 08             	mov    0x8(%ebp),%eax
 16c:	0f b6 00             	movzbl (%eax),%eax
 16f:	84 c0                	test   %al,%al
 171:	75 e2                	jne    155 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 173:	b8 00 00 00 00       	mov    $0x0,%eax
}
 178:	c9                   	leave  
 179:	c3                   	ret    

0000017a <gets>:

char*
gets(char *buf, int max)
{
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
 17d:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 180:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 187:	eb 44                	jmp    1cd <gets+0x53>
    cc = read(0, &c, 1);
 189:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 190:	00 
 191:	8d 45 ef             	lea    -0x11(%ebp),%eax
 194:	89 44 24 04          	mov    %eax,0x4(%esp)
 198:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 19f:	e8 3c 01 00 00       	call   2e0 <read>
 1a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ab:	7e 2d                	jle    1da <gets+0x60>
      break;
    buf[i++] = c;
 1ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1b0:	03 45 08             	add    0x8(%ebp),%eax
 1b3:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
 1b7:	88 10                	mov    %dl,(%eax)
 1b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(c == '\n' || c == '\r')
 1bd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c1:	3c 0a                	cmp    $0xa,%al
 1c3:	74 16                	je     1db <gets+0x61>
 1c5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c9:	3c 0d                	cmp    $0xd,%al
 1cb:	74 0e                	je     1db <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d0:	83 c0 01             	add    $0x1,%eax
 1d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1d6:	7c b1                	jl     189 <gets+0xf>
 1d8:	eb 01                	jmp    1db <gets+0x61>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1da:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1de:	03 45 08             	add    0x8(%ebp),%eax
 1e1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e7:	c9                   	leave  
 1e8:	c3                   	ret    

000001e9 <stat>:

int
stat(char *n, struct stat *st)
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1f6:	00 
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
 1fa:	89 04 24             	mov    %eax,(%esp)
 1fd:	e8 06 01 00 00       	call   308 <open>
 202:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 209:	79 07                	jns    212 <stat+0x29>
    return -1;
 20b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 210:	eb 23                	jmp    235 <stat+0x4c>
  r = fstat(fd, st);
 212:	8b 45 0c             	mov    0xc(%ebp),%eax
 215:	89 44 24 04          	mov    %eax,0x4(%esp)
 219:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21c:	89 04 24             	mov    %eax,(%esp)
 21f:	e8 fc 00 00 00       	call   320 <fstat>
 224:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 227:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22a:	89 04 24             	mov    %eax,(%esp)
 22d:	e8 be 00 00 00       	call   2f0 <close>
  return r;
 232:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 235:	c9                   	leave  
 236:	c3                   	ret    

00000237 <atoi>:

int
atoi(const char *s)
{
 237:	55                   	push   %ebp
 238:	89 e5                	mov    %esp,%ebp
 23a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 23d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 244:	eb 23                	jmp    269 <atoi+0x32>
    n = n*10 + *s++ - '0';
 246:	8b 55 fc             	mov    -0x4(%ebp),%edx
 249:	89 d0                	mov    %edx,%eax
 24b:	c1 e0 02             	shl    $0x2,%eax
 24e:	01 d0                	add    %edx,%eax
 250:	01 c0                	add    %eax,%eax
 252:	89 c2                	mov    %eax,%edx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	0f b6 00             	movzbl (%eax),%eax
 25a:	0f be c0             	movsbl %al,%eax
 25d:	01 d0                	add    %edx,%eax
 25f:	83 e8 30             	sub    $0x30,%eax
 262:	89 45 fc             	mov    %eax,-0x4(%ebp)
 265:	83 45 08 01          	addl   $0x1,0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 269:	8b 45 08             	mov    0x8(%ebp),%eax
 26c:	0f b6 00             	movzbl (%eax),%eax
 26f:	3c 2f                	cmp    $0x2f,%al
 271:	7e 0a                	jle    27d <atoi+0x46>
 273:	8b 45 08             	mov    0x8(%ebp),%eax
 276:	0f b6 00             	movzbl (%eax),%eax
 279:	3c 39                	cmp    $0x39,%al
 27b:	7e c9                	jle    246 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 27d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 280:	c9                   	leave  
 281:	c3                   	ret    

00000282 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 282:	55                   	push   %ebp
 283:	89 e5                	mov    %esp,%ebp
 285:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 288:	8b 45 08             	mov    0x8(%ebp),%eax
 28b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 28e:	8b 45 0c             	mov    0xc(%ebp),%eax
 291:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 294:	eb 13                	jmp    2a9 <memmove+0x27>
    *dst++ = *src++;
 296:	8b 45 f8             	mov    -0x8(%ebp),%eax
 299:	0f b6 10             	movzbl (%eax),%edx
 29c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 29f:	88 10                	mov    %dl,(%eax)
 2a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2a5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2ad:	0f 9f c0             	setg   %al
 2b0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 2b4:	84 c0                	test   %al,%al
 2b6:	75 de                	jne    296 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2bb:	c9                   	leave  
 2bc:	c3                   	ret    
 2bd:	90                   	nop
 2be:	90                   	nop
 2bf:	90                   	nop

000002c0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c0:	b8 01 00 00 00       	mov    $0x1,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <exit>:
SYSCALL(exit)
 2c8:	b8 02 00 00 00       	mov    $0x2,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <wait>:
SYSCALL(wait)
 2d0:	b8 03 00 00 00       	mov    $0x3,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <pipe>:
SYSCALL(pipe)
 2d8:	b8 04 00 00 00       	mov    $0x4,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <read>:
SYSCALL(read)
 2e0:	b8 05 00 00 00       	mov    $0x5,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <write>:
SYSCALL(write)
 2e8:	b8 10 00 00 00       	mov    $0x10,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <close>:
SYSCALL(close)
 2f0:	b8 15 00 00 00       	mov    $0x15,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <kill>:
SYSCALL(kill)
 2f8:	b8 06 00 00 00       	mov    $0x6,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <exec>:
SYSCALL(exec)
 300:	b8 07 00 00 00       	mov    $0x7,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <open>:
SYSCALL(open)
 308:	b8 0f 00 00 00       	mov    $0xf,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <mknod>:
SYSCALL(mknod)
 310:	b8 11 00 00 00       	mov    $0x11,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <unlink>:
SYSCALL(unlink)
 318:	b8 12 00 00 00       	mov    $0x12,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <fstat>:
SYSCALL(fstat)
 320:	b8 08 00 00 00       	mov    $0x8,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <link>:
SYSCALL(link)
 328:	b8 13 00 00 00       	mov    $0x13,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <mkdir>:
SYSCALL(mkdir)
 330:	b8 14 00 00 00       	mov    $0x14,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <chdir>:
SYSCALL(chdir)
 338:	b8 09 00 00 00       	mov    $0x9,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <dup>:
SYSCALL(dup)
 340:	b8 0a 00 00 00       	mov    $0xa,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <getpid>:
SYSCALL(getpid)
 348:	b8 0b 00 00 00       	mov    $0xb,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <sbrk>:
SYSCALL(sbrk)
 350:	b8 0c 00 00 00       	mov    $0xc,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <sleep>:
SYSCALL(sleep)
 358:	b8 0d 00 00 00       	mov    $0xd,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <uptime>:
SYSCALL(uptime)
 360:	b8 0e 00 00 00       	mov    $0xe,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <thread_create>:
SYSCALL(thread_create)
 368:	b8 16 00 00 00       	mov    $0x16,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <thread_getId>:
SYSCALL(thread_getId)
 370:	b8 17 00 00 00       	mov    $0x17,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <thread_getProcId>:
SYSCALL(thread_getProcId)
 378:	b8 18 00 00 00       	mov    $0x18,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <thread_join>:
SYSCALL(thread_join)
 380:	b8 19 00 00 00       	mov    $0x19,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <thread_exit>:
SYSCALL(thread_exit)
 388:	b8 1a 00 00 00       	mov    $0x1a,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <binary_semaphore_create>:
SYSCALL(binary_semaphore_create)
 390:	b8 1b 00 00 00       	mov    $0x1b,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <binary_semaphore_down>:
SYSCALL(binary_semaphore_down)
 398:	b8 1c 00 00 00       	mov    $0x1c,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <binary_semaphore_up>:
SYSCALL(binary_semaphore_up)
 3a0:	b8 1d 00 00 00       	mov    $0x1d,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3a8:	55                   	push   %ebp
 3a9:	89 e5                	mov    %esp,%ebp
 3ab:	83 ec 28             	sub    $0x28,%esp
 3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3b4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3bb:	00 
 3bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3bf:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
 3c6:	89 04 24             	mov    %eax,(%esp)
 3c9:	e8 1a ff ff ff       	call   2e8 <write>
}
 3ce:	c9                   	leave  
 3cf:	c3                   	ret    

000003d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3d6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3dd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3e1:	74 17                	je     3fa <printint+0x2a>
 3e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3e7:	79 11                	jns    3fa <printint+0x2a>
    neg = 1;
 3e9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3f3:	f7 d8                	neg    %eax
 3f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3f8:	eb 06                	jmp    400 <printint+0x30>
  } else {
    x = xx;
 3fa:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 400:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 407:	8b 4d 10             	mov    0x10(%ebp),%ecx
 40a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 40d:	ba 00 00 00 00       	mov    $0x0,%edx
 412:	f7 f1                	div    %ecx
 414:	89 d0                	mov    %edx,%eax
 416:	0f b6 90 24 10 00 00 	movzbl 0x1024(%eax),%edx
 41d:	8d 45 dc             	lea    -0x24(%ebp),%eax
 420:	03 45 f4             	add    -0xc(%ebp),%eax
 423:	88 10                	mov    %dl,(%eax)
 425:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
 429:	8b 55 10             	mov    0x10(%ebp),%edx
 42c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 42f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 432:	ba 00 00 00 00       	mov    $0x0,%edx
 437:	f7 75 d4             	divl   -0x2c(%ebp)
 43a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 43d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 441:	75 c4                	jne    407 <printint+0x37>
  if(neg)
 443:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 447:	74 2a                	je     473 <printint+0xa3>
    buf[i++] = '-';
 449:	8d 45 dc             	lea    -0x24(%ebp),%eax
 44c:	03 45 f4             	add    -0xc(%ebp),%eax
 44f:	c6 00 2d             	movb   $0x2d,(%eax)
 452:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
 456:	eb 1b                	jmp    473 <printint+0xa3>
    putc(fd, buf[i]);
 458:	8d 45 dc             	lea    -0x24(%ebp),%eax
 45b:	03 45 f4             	add    -0xc(%ebp),%eax
 45e:	0f b6 00             	movzbl (%eax),%eax
 461:	0f be c0             	movsbl %al,%eax
 464:	89 44 24 04          	mov    %eax,0x4(%esp)
 468:	8b 45 08             	mov    0x8(%ebp),%eax
 46b:	89 04 24             	mov    %eax,(%esp)
 46e:	e8 35 ff ff ff       	call   3a8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 473:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 477:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 47b:	79 db                	jns    458 <printint+0x88>
    putc(fd, buf[i]);
}
 47d:	c9                   	leave  
 47e:	c3                   	ret    

0000047f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 47f:	55                   	push   %ebp
 480:	89 e5                	mov    %esp,%ebp
 482:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 485:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 48c:	8d 45 0c             	lea    0xc(%ebp),%eax
 48f:	83 c0 04             	add    $0x4,%eax
 492:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 495:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 49c:	e9 7d 01 00 00       	jmp    61e <printf+0x19f>
    c = fmt[i] & 0xff;
 4a1:	8b 55 0c             	mov    0xc(%ebp),%edx
 4a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4a7:	01 d0                	add    %edx,%eax
 4a9:	0f b6 00             	movzbl (%eax),%eax
 4ac:	0f be c0             	movsbl %al,%eax
 4af:	25 ff 00 00 00       	and    $0xff,%eax
 4b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4b7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4bb:	75 2c                	jne    4e9 <printf+0x6a>
      if(c == '%'){
 4bd:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4c1:	75 0c                	jne    4cf <printf+0x50>
        state = '%';
 4c3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4ca:	e9 4b 01 00 00       	jmp    61a <printf+0x19b>
      } else {
        putc(fd, c);
 4cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d2:	0f be c0             	movsbl %al,%eax
 4d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d9:	8b 45 08             	mov    0x8(%ebp),%eax
 4dc:	89 04 24             	mov    %eax,(%esp)
 4df:	e8 c4 fe ff ff       	call   3a8 <putc>
 4e4:	e9 31 01 00 00       	jmp    61a <printf+0x19b>
      }
    } else if(state == '%'){
 4e9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4ed:	0f 85 27 01 00 00    	jne    61a <printf+0x19b>
      if(c == 'd'){
 4f3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4f7:	75 2d                	jne    526 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 4f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4fc:	8b 00                	mov    (%eax),%eax
 4fe:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 505:	00 
 506:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 50d:	00 
 50e:	89 44 24 04          	mov    %eax,0x4(%esp)
 512:	8b 45 08             	mov    0x8(%ebp),%eax
 515:	89 04 24             	mov    %eax,(%esp)
 518:	e8 b3 fe ff ff       	call   3d0 <printint>
        ap++;
 51d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 521:	e9 ed 00 00 00       	jmp    613 <printf+0x194>
      } else if(c == 'x' || c == 'p'){
 526:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 52a:	74 06                	je     532 <printf+0xb3>
 52c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 530:	75 2d                	jne    55f <printf+0xe0>
        printint(fd, *ap, 16, 0);
 532:	8b 45 e8             	mov    -0x18(%ebp),%eax
 535:	8b 00                	mov    (%eax),%eax
 537:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 53e:	00 
 53f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 546:	00 
 547:	89 44 24 04          	mov    %eax,0x4(%esp)
 54b:	8b 45 08             	mov    0x8(%ebp),%eax
 54e:	89 04 24             	mov    %eax,(%esp)
 551:	e8 7a fe ff ff       	call   3d0 <printint>
        ap++;
 556:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 55a:	e9 b4 00 00 00       	jmp    613 <printf+0x194>
      } else if(c == 's'){
 55f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 563:	75 46                	jne    5ab <printf+0x12c>
        s = (char*)*ap;
 565:	8b 45 e8             	mov    -0x18(%ebp),%eax
 568:	8b 00                	mov    (%eax),%eax
 56a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 56d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 571:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 575:	75 27                	jne    59e <printf+0x11f>
          s = "(null)";
 577:	c7 45 f4 40 0c 00 00 	movl   $0xc40,-0xc(%ebp)
        while(*s != 0){
 57e:	eb 1e                	jmp    59e <printf+0x11f>
          putc(fd, *s);
 580:	8b 45 f4             	mov    -0xc(%ebp),%eax
 583:	0f b6 00             	movzbl (%eax),%eax
 586:	0f be c0             	movsbl %al,%eax
 589:	89 44 24 04          	mov    %eax,0x4(%esp)
 58d:	8b 45 08             	mov    0x8(%ebp),%eax
 590:	89 04 24             	mov    %eax,(%esp)
 593:	e8 10 fe ff ff       	call   3a8 <putc>
          s++;
 598:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 59c:	eb 01                	jmp    59f <printf+0x120>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 59e:	90                   	nop
 59f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a2:	0f b6 00             	movzbl (%eax),%eax
 5a5:	84 c0                	test   %al,%al
 5a7:	75 d7                	jne    580 <printf+0x101>
 5a9:	eb 68                	jmp    613 <printf+0x194>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5ab:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5af:	75 1d                	jne    5ce <printf+0x14f>
        putc(fd, *ap);
 5b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b4:	8b 00                	mov    (%eax),%eax
 5b6:	0f be c0             	movsbl %al,%eax
 5b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bd:	8b 45 08             	mov    0x8(%ebp),%eax
 5c0:	89 04 24             	mov    %eax,(%esp)
 5c3:	e8 e0 fd ff ff       	call   3a8 <putc>
        ap++;
 5c8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5cc:	eb 45                	jmp    613 <printf+0x194>
      } else if(c == '%'){
 5ce:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5d2:	75 17                	jne    5eb <printf+0x16c>
        putc(fd, c);
 5d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d7:	0f be c0             	movsbl %al,%eax
 5da:	89 44 24 04          	mov    %eax,0x4(%esp)
 5de:	8b 45 08             	mov    0x8(%ebp),%eax
 5e1:	89 04 24             	mov    %eax,(%esp)
 5e4:	e8 bf fd ff ff       	call   3a8 <putc>
 5e9:	eb 28                	jmp    613 <printf+0x194>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5eb:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5f2:	00 
 5f3:	8b 45 08             	mov    0x8(%ebp),%eax
 5f6:	89 04 24             	mov    %eax,(%esp)
 5f9:	e8 aa fd ff ff       	call   3a8 <putc>
        putc(fd, c);
 5fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 601:	0f be c0             	movsbl %al,%eax
 604:	89 44 24 04          	mov    %eax,0x4(%esp)
 608:	8b 45 08             	mov    0x8(%ebp),%eax
 60b:	89 04 24             	mov    %eax,(%esp)
 60e:	e8 95 fd ff ff       	call   3a8 <putc>
      }
      state = 0;
 613:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 61a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 61e:	8b 55 0c             	mov    0xc(%ebp),%edx
 621:	8b 45 f0             	mov    -0x10(%ebp),%eax
 624:	01 d0                	add    %edx,%eax
 626:	0f b6 00             	movzbl (%eax),%eax
 629:	84 c0                	test   %al,%al
 62b:	0f 85 70 fe ff ff    	jne    4a1 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 631:	c9                   	leave  
 632:	c3                   	ret    
 633:	90                   	nop

00000634 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 634:	55                   	push   %ebp
 635:	89 e5                	mov    %esp,%ebp
 637:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
 63d:	83 e8 08             	sub    $0x8,%eax
 640:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 643:	a1 40 10 00 00       	mov    0x1040,%eax
 648:	89 45 fc             	mov    %eax,-0x4(%ebp)
 64b:	eb 24                	jmp    671 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 64d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 650:	8b 00                	mov    (%eax),%eax
 652:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 655:	77 12                	ja     669 <free+0x35>
 657:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 65d:	77 24                	ja     683 <free+0x4f>
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	8b 00                	mov    (%eax),%eax
 664:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 667:	77 1a                	ja     683 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 669:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66c:	8b 00                	mov    (%eax),%eax
 66e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 671:	8b 45 f8             	mov    -0x8(%ebp),%eax
 674:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 677:	76 d4                	jbe    64d <free+0x19>
 679:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67c:	8b 00                	mov    (%eax),%eax
 67e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 681:	76 ca                	jbe    64d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 683:	8b 45 f8             	mov    -0x8(%ebp),%eax
 686:	8b 40 04             	mov    0x4(%eax),%eax
 689:	c1 e0 03             	shl    $0x3,%eax
 68c:	89 c2                	mov    %eax,%edx
 68e:	03 55 f8             	add    -0x8(%ebp),%edx
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 00                	mov    (%eax),%eax
 696:	39 c2                	cmp    %eax,%edx
 698:	75 24                	jne    6be <free+0x8a>
    bp->s.size += p->s.ptr->s.size;
 69a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69d:	8b 50 04             	mov    0x4(%eax),%edx
 6a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a3:	8b 00                	mov    (%eax),%eax
 6a5:	8b 40 04             	mov    0x4(%eax),%eax
 6a8:	01 c2                	add    %eax,%edx
 6aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ad:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b3:	8b 00                	mov    (%eax),%eax
 6b5:	8b 10                	mov    (%eax),%edx
 6b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ba:	89 10                	mov    %edx,(%eax)
 6bc:	eb 0a                	jmp    6c8 <free+0x94>
  } else
    bp->s.ptr = p->s.ptr;
 6be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c1:	8b 10                	mov    (%eax),%edx
 6c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cb:	8b 40 04             	mov    0x4(%eax),%eax
 6ce:	c1 e0 03             	shl    $0x3,%eax
 6d1:	03 45 fc             	add    -0x4(%ebp),%eax
 6d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6d7:	75 20                	jne    6f9 <free+0xc5>
    p->s.size += bp->s.size;
 6d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dc:	8b 50 04             	mov    0x4(%eax),%edx
 6df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e2:	8b 40 04             	mov    0x4(%eax),%eax
 6e5:	01 c2                	add    %eax,%edx
 6e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ea:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f0:	8b 10                	mov    (%eax),%edx
 6f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f5:	89 10                	mov    %edx,(%eax)
 6f7:	eb 08                	jmp    701 <free+0xcd>
  } else
    p->s.ptr = bp;
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6ff:	89 10                	mov    %edx,(%eax)
  freep = p;
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	a3 40 10 00 00       	mov    %eax,0x1040
}
 709:	c9                   	leave  
 70a:	c3                   	ret    

0000070b <morecore>:

static Header*
morecore(uint nu)
{
 70b:	55                   	push   %ebp
 70c:	89 e5                	mov    %esp,%ebp
 70e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 711:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 718:	77 07                	ja     721 <morecore+0x16>
    nu = 4096;
 71a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 721:	8b 45 08             	mov    0x8(%ebp),%eax
 724:	c1 e0 03             	shl    $0x3,%eax
 727:	89 04 24             	mov    %eax,(%esp)
 72a:	e8 21 fc ff ff       	call   350 <sbrk>
 72f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 732:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 736:	75 07                	jne    73f <morecore+0x34>
    return 0;
 738:	b8 00 00 00 00       	mov    $0x0,%eax
 73d:	eb 22                	jmp    761 <morecore+0x56>
  hp = (Header*)p;
 73f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 742:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 745:	8b 45 f0             	mov    -0x10(%ebp),%eax
 748:	8b 55 08             	mov    0x8(%ebp),%edx
 74b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 74e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 751:	83 c0 08             	add    $0x8,%eax
 754:	89 04 24             	mov    %eax,(%esp)
 757:	e8 d8 fe ff ff       	call   634 <free>
  return freep;
 75c:	a1 40 10 00 00       	mov    0x1040,%eax
}
 761:	c9                   	leave  
 762:	c3                   	ret    

00000763 <malloc>:

void*
malloc(uint nbytes)
{
 763:	55                   	push   %ebp
 764:	89 e5                	mov    %esp,%ebp
 766:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 769:	8b 45 08             	mov    0x8(%ebp),%eax
 76c:	83 c0 07             	add    $0x7,%eax
 76f:	c1 e8 03             	shr    $0x3,%eax
 772:	83 c0 01             	add    $0x1,%eax
 775:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 778:	a1 40 10 00 00       	mov    0x1040,%eax
 77d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 780:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 784:	75 23                	jne    7a9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 786:	c7 45 f0 38 10 00 00 	movl   $0x1038,-0x10(%ebp)
 78d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 790:	a3 40 10 00 00       	mov    %eax,0x1040
 795:	a1 40 10 00 00       	mov    0x1040,%eax
 79a:	a3 38 10 00 00       	mov    %eax,0x1038
    base.s.size = 0;
 79f:	c7 05 3c 10 00 00 00 	movl   $0x0,0x103c
 7a6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ac:	8b 00                	mov    (%eax),%eax
 7ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b4:	8b 40 04             	mov    0x4(%eax),%eax
 7b7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7ba:	72 4d                	jb     809 <malloc+0xa6>
      if(p->s.size == nunits)
 7bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bf:	8b 40 04             	mov    0x4(%eax),%eax
 7c2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7c5:	75 0c                	jne    7d3 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ca:	8b 10                	mov    (%eax),%edx
 7cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7cf:	89 10                	mov    %edx,(%eax)
 7d1:	eb 26                	jmp    7f9 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d6:	8b 40 04             	mov    0x4(%eax),%eax
 7d9:	89 c2                	mov    %eax,%edx
 7db:	2b 55 ec             	sub    -0x14(%ebp),%edx
 7de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e7:	8b 40 04             	mov    0x4(%eax),%eax
 7ea:	c1 e0 03             	shl    $0x3,%eax
 7ed:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f3:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7f6:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fc:	a3 40 10 00 00       	mov    %eax,0x1040
      return (void*)(p + 1);
 801:	8b 45 f4             	mov    -0xc(%ebp),%eax
 804:	83 c0 08             	add    $0x8,%eax
 807:	eb 38                	jmp    841 <malloc+0xde>
    }
    if(p == freep)
 809:	a1 40 10 00 00       	mov    0x1040,%eax
 80e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 811:	75 1b                	jne    82e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 813:	8b 45 ec             	mov    -0x14(%ebp),%eax
 816:	89 04 24             	mov    %eax,(%esp)
 819:	e8 ed fe ff ff       	call   70b <morecore>
 81e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 821:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 825:	75 07                	jne    82e <malloc+0xcb>
        return 0;
 827:	b8 00 00 00 00       	mov    $0x0,%eax
 82c:	eb 13                	jmp    841 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 831:	89 45 f0             	mov    %eax,-0x10(%ebp)
 834:	8b 45 f4             	mov    -0xc(%ebp),%eax
 837:	8b 00                	mov    (%eax),%eax
 839:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 83c:	e9 70 ff ff ff       	jmp    7b1 <malloc+0x4e>
}
 841:	c9                   	leave  
 842:	c3                   	ret    
 843:	90                   	nop

00000844 <semaphore_create>:
#include "semaphore.h"
#include "types.h"
#include "user.h"


struct semaphore* semaphore_create(int initial_semaphore_value){
 844:	55                   	push   %ebp
 845:	89 e5                	mov    %esp,%ebp
 847:	83 ec 28             	sub    $0x28,%esp
  struct semaphore* sem=malloc(sizeof(struct semaphore)); 
 84a:	c7 04 24 10 00 00 00 	movl   $0x10,(%esp)
 851:	e8 0d ff ff ff       	call   763 <malloc>
 856:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // acquire semaphors
  sem->s1 = binary_semaphore_create(1);
 859:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 860:	e8 2b fb ff ff       	call   390 <binary_semaphore_create>
 865:	8b 55 f4             	mov    -0xc(%ebp),%edx
 868:	89 02                	mov    %eax,(%edx)
  
  // s2 should be initialized with the min{1,initial_semaphore_value}
  if(initial_semaphore_value >= 1){
 86a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 86e:	7e 14                	jle    884 <semaphore_create+0x40>
    sem->s2 = binary_semaphore_create(1);
 870:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 877:	e8 14 fb ff ff       	call   390 <binary_semaphore_create>
 87c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 87f:	89 42 04             	mov    %eax,0x4(%edx)
 882:	eb 11                	jmp    895 <semaphore_create+0x51>
  }else{
    sem->s2 = binary_semaphore_create(initial_semaphore_value);
 884:	8b 45 08             	mov    0x8(%ebp),%eax
 887:	89 04 24             	mov    %eax,(%esp)
 88a:	e8 01 fb ff ff       	call   390 <binary_semaphore_create>
 88f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 892:	89 42 04             	mov    %eax,0x4(%edx)
  }
  
  if(sem->s1 == -1 || sem->s2 == -1){
 895:	8b 45 f4             	mov    -0xc(%ebp),%eax
 898:	8b 00                	mov    (%eax),%eax
 89a:	83 f8 ff             	cmp    $0xffffffff,%eax
 89d:	74 0b                	je     8aa <semaphore_create+0x66>
 89f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a2:	8b 40 04             	mov    0x4(%eax),%eax
 8a5:	83 f8 ff             	cmp    $0xffffffff,%eax
 8a8:	75 26                	jne    8d0 <semaphore_create+0x8c>
     printf(1,"we had a probalem initialize in semaphore_create\n");
 8aa:	c7 44 24 04 48 0c 00 	movl   $0xc48,0x4(%esp)
 8b1:	00 
 8b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 8b9:	e8 c1 fb ff ff       	call   47f <printf>
     free(sem);
 8be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c1:	89 04 24             	mov    %eax,(%esp)
 8c4:	e8 6b fd ff ff       	call   634 <free>
     return 0;
 8c9:	b8 00 00 00 00       	mov    $0x0,%eax
 8ce:	eb 15                	jmp    8e5 <semaphore_create+0xa1>
  }
  //initialize value
  sem->value = initial_semaphore_value;//dynamic
 8d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d3:	8b 55 08             	mov    0x8(%ebp),%edx
 8d6:	89 50 08             	mov    %edx,0x8(%eax)
  sem->initial_value = initial_semaphore_value;//static
 8d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8dc:	8b 55 08             	mov    0x8(%ebp),%edx
 8df:	89 50 0c             	mov    %edx,0xc(%eax)
  
  return sem;
 8e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 8e5:	c9                   	leave  
 8e6:	c3                   	ret    

000008e7 <semaphore_down>:
void semaphore_down(struct semaphore* sem ){
 8e7:	55                   	push   %ebp
 8e8:	89 e5                	mov    %esp,%ebp
 8ea:	83 ec 18             	sub    $0x18,%esp
  binary_semaphore_down(sem->s2);
 8ed:	8b 45 08             	mov    0x8(%ebp),%eax
 8f0:	8b 40 04             	mov    0x4(%eax),%eax
 8f3:	89 04 24             	mov    %eax,(%esp)
 8f6:	e8 9d fa ff ff       	call   398 <binary_semaphore_down>
  binary_semaphore_down(sem->s1);
 8fb:	8b 45 08             	mov    0x8(%ebp),%eax
 8fe:	8b 00                	mov    (%eax),%eax
 900:	89 04 24             	mov    %eax,(%esp)
 903:	e8 90 fa ff ff       	call   398 <binary_semaphore_down>
  sem->value--;	
 908:	8b 45 08             	mov    0x8(%ebp),%eax
 90b:	8b 40 08             	mov    0x8(%eax),%eax
 90e:	8d 50 ff             	lea    -0x1(%eax),%edx
 911:	8b 45 08             	mov    0x8(%ebp),%eax
 914:	89 50 08             	mov    %edx,0x8(%eax)
  if(sem->value > 0){
 917:	8b 45 08             	mov    0x8(%ebp),%eax
 91a:	8b 40 08             	mov    0x8(%eax),%eax
 91d:	85 c0                	test   %eax,%eax
 91f:	7e 0e                	jle    92f <semaphore_down+0x48>
   binary_semaphore_up(sem->s2);
 921:	8b 45 08             	mov    0x8(%ebp),%eax
 924:	8b 40 04             	mov    0x4(%eax),%eax
 927:	89 04 24             	mov    %eax,(%esp)
 92a:	e8 71 fa ff ff       	call   3a0 <binary_semaphore_up>
  }
  binary_semaphore_up(sem->s1); 
 92f:	8b 45 08             	mov    0x8(%ebp),%eax
 932:	8b 00                	mov    (%eax),%eax
 934:	89 04 24             	mov    %eax,(%esp)
 937:	e8 64 fa ff ff       	call   3a0 <binary_semaphore_up>
}
 93c:	c9                   	leave  
 93d:	c3                   	ret    

0000093e <semaphore_up>:
void semaphore_up(struct semaphore* sem ){
 93e:	55                   	push   %ebp
 93f:	89 e5                	mov    %esp,%ebp
 941:	83 ec 18             	sub    $0x18,%esp
  binary_semaphore_down(sem->s1);
 944:	8b 45 08             	mov    0x8(%ebp),%eax
 947:	8b 00                	mov    (%eax),%eax
 949:	89 04 24             	mov    %eax,(%esp)
 94c:	e8 47 fa ff ff       	call   398 <binary_semaphore_down>
  sem->value++;	
 951:	8b 45 08             	mov    0x8(%ebp),%eax
 954:	8b 40 08             	mov    0x8(%eax),%eax
 957:	8d 50 01             	lea    0x1(%eax),%edx
 95a:	8b 45 08             	mov    0x8(%ebp),%eax
 95d:	89 50 08             	mov    %edx,0x8(%eax)
  if(sem->value ==1){
 960:	8b 45 08             	mov    0x8(%ebp),%eax
 963:	8b 40 08             	mov    0x8(%eax),%eax
 966:	83 f8 01             	cmp    $0x1,%eax
 969:	75 0e                	jne    979 <semaphore_up+0x3b>
   binary_semaphore_up(sem->s2); 
 96b:	8b 45 08             	mov    0x8(%ebp),%eax
 96e:	8b 40 04             	mov    0x4(%eax),%eax
 971:	89 04 24             	mov    %eax,(%esp)
 974:	e8 27 fa ff ff       	call   3a0 <binary_semaphore_up>
   }
  binary_semaphore_up(sem->s1);
 979:	8b 45 08             	mov    0x8(%ebp),%eax
 97c:	8b 00                	mov    (%eax),%eax
 97e:	89 04 24             	mov    %eax,(%esp)
 981:	e8 1a fa ff ff       	call   3a0 <binary_semaphore_up>
}
 986:	c9                   	leave  
 987:	c3                   	ret    

00000988 <semaphore_free>:

void semaphore_free(struct semaphore* sem){
 988:	55                   	push   %ebp
 989:	89 e5                	mov    %esp,%ebp
 98b:	83 ec 18             	sub    $0x18,%esp
  free(sem);
 98e:	8b 45 08             	mov    0x8(%ebp),%eax
 991:	89 04 24             	mov    %eax,(%esp)
 994:	e8 9b fc ff ff       	call   634 <free>
}
 999:	c9                   	leave  
 99a:	c3                   	ret    
 99b:	90                   	nop

0000099c <BB_create>:
#include "types.h"
#include "user.h"


struct BB* 
BB_create(int max_capacity){
 99c:	55                   	push   %ebp
 99d:	89 e5                	mov    %esp,%ebp
 99f:	83 ec 38             	sub    $0x38,%esp
  //initialize
  struct BB* buf = malloc(sizeof(struct BB));
 9a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
 9a9:	e8 b5 fd ff ff       	call   763 <malloc>
 9ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(buf,0,sizeof(struct BB));
 9b1:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
 9b8:	00 
 9b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 9c0:	00 
 9c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c4:	89 04 24             	mov    %eax,(%esp)
 9c7:	e8 57 f7 ff ff       	call   123 <memset>
 
  buf->buffer_size = max_capacity;
 9cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9cf:	8b 55 08             	mov    0x8(%ebp),%edx
 9d2:	89 10                	mov    %edx,(%eax)
  buf->mutex = binary_semaphore_create(1);  
 9d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 9db:	e8 b0 f9 ff ff       	call   390 <binary_semaphore_create>
 9e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 9e3:	89 42 04             	mov    %eax,0x4(%edx)
  buf->empty = semaphore_create(max_capacity);
 9e6:	8b 45 08             	mov    0x8(%ebp),%eax
 9e9:	89 04 24             	mov    %eax,(%esp)
 9ec:	e8 53 fe ff ff       	call   844 <semaphore_create>
 9f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 9f4:	89 42 08             	mov    %eax,0x8(%edx)
  buf->full = semaphore_create(0);
 9f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 9fe:	e8 41 fe ff ff       	call   844 <semaphore_create>
 a03:	8b 55 f4             	mov    -0xc(%ebp),%edx
 a06:	89 42 0c             	mov    %eax,0xc(%edx)
  buf->pointer_to_elements = malloc(sizeof(void*)*max_capacity);
 a09:	8b 45 08             	mov    0x8(%ebp),%eax
 a0c:	c1 e0 02             	shl    $0x2,%eax
 a0f:	89 04 24             	mov    %eax,(%esp)
 a12:	e8 4c fd ff ff       	call   763 <malloc>
 a17:	8b 55 f4             	mov    -0xc(%ebp),%edx
 a1a:	89 42 1c             	mov    %eax,0x1c(%edx)
  memset(buf->pointer_to_elements,0,sizeof(void*)*max_capacity);
 a1d:	8b 45 08             	mov    0x8(%ebp),%eax
 a20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a2a:	8b 40 1c             	mov    0x1c(%eax),%eax
 a2d:	89 54 24 08          	mov    %edx,0x8(%esp)
 a31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 a38:	00 
 a39:	89 04 24             	mov    %eax,(%esp)
 a3c:	e8 e2 f6 ff ff       	call   123 <memset>
  buf->count = 0;
 a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a44:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
  //check the semaphorses
  if(buf->mutex == -1 || buf->empty == 0 || buf->full == 0){
 a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4e:	8b 40 04             	mov    0x4(%eax),%eax
 a51:	83 f8 ff             	cmp    $0xffffffff,%eax
 a54:	74 14                	je     a6a <BB_create+0xce>
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	8b 40 08             	mov    0x8(%eax),%eax
 a5c:	85 c0                	test   %eax,%eax
 a5e:	74 0a                	je     a6a <BB_create+0xce>
 a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a63:	8b 40 0c             	mov    0xc(%eax),%eax
 a66:	85 c0                	test   %eax,%eax
 a68:	75 44                	jne    aae <BB_create+0x112>
   printf(1,"we had a problam getting semaphores at BB create mutex %d empty %d full %d\n",buf->mutex,buf->empty,buf->full);
 a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6d:	8b 48 0c             	mov    0xc(%eax),%ecx
 a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a73:	8b 50 08             	mov    0x8(%eax),%edx
 a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a79:	8b 40 04             	mov    0x4(%eax),%eax
 a7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
 a80:	89 54 24 0c          	mov    %edx,0xc(%esp)
 a84:	89 44 24 08          	mov    %eax,0x8(%esp)
 a88:	c7 44 24 04 7c 0c 00 	movl   $0xc7c,0x4(%esp)
 a8f:	00 
 a90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 a97:	e8 e3 f9 ff ff       	call   47f <printf>
   BB_free(buf);
 a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9f:	89 04 24             	mov    %eax,(%esp)
 aa2:	e8 47 01 00 00       	call   bee <BB_free>
   
   buf =0;  
 aa7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  }
  return buf;
 aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
 ab1:	c9                   	leave  
 ab2:	c3                   	ret    

00000ab3 <BB_put>:

void BB_put(struct BB* bb, void* element)
{ 
 ab3:	55                   	push   %ebp
 ab4:	89 e5                	mov    %esp,%ebp
 ab6:	83 ec 18             	sub    $0x18,%esp
  semaphore_down(bb->empty);
 ab9:	8b 45 08             	mov    0x8(%ebp),%eax
 abc:	8b 40 08             	mov    0x8(%eax),%eax
 abf:	89 04 24             	mov    %eax,(%esp)
 ac2:	e8 20 fe ff ff       	call   8e7 <semaphore_down>
  binary_semaphore_down(bb->mutex);
 ac7:	8b 45 08             	mov    0x8(%ebp),%eax
 aca:	8b 40 04             	mov    0x4(%eax),%eax
 acd:	89 04 24             	mov    %eax,(%esp)
 ad0:	e8 c3 f8 ff ff       	call   398 <binary_semaphore_down>
   //insert item
  bb->pointer_to_elements[bb->count] = element;
 ad5:	8b 45 08             	mov    0x8(%ebp),%eax
 ad8:	8b 50 1c             	mov    0x1c(%eax),%edx
 adb:	8b 45 08             	mov    0x8(%ebp),%eax
 ade:	8b 40 10             	mov    0x10(%eax),%eax
 ae1:	c1 e0 02             	shl    $0x2,%eax
 ae4:	01 c2                	add    %eax,%edx
 ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
 ae9:	89 02                	mov    %eax,(%edx)
  bb->count++;
 aeb:	8b 45 08             	mov    0x8(%ebp),%eax
 aee:	8b 40 10             	mov    0x10(%eax),%eax
 af1:	8d 50 01             	lea    0x1(%eax),%edx
 af4:	8b 45 08             	mov    0x8(%ebp),%eax
 af7:	89 50 10             	mov    %edx,0x10(%eax)
  binary_semaphore_up(bb->mutex);
 afa:	8b 45 08             	mov    0x8(%ebp),%eax
 afd:	8b 40 04             	mov    0x4(%eax),%eax
 b00:	89 04 24             	mov    %eax,(%esp)
 b03:	e8 98 f8 ff ff       	call   3a0 <binary_semaphore_up>
  semaphore_up(bb->full);
 b08:	8b 45 08             	mov    0x8(%ebp),%eax
 b0b:	8b 40 0c             	mov    0xc(%eax),%eax
 b0e:	89 04 24             	mov    %eax,(%esp)
 b11:	e8 28 fe ff ff       	call   93e <semaphore_up>
}
 b16:	c9                   	leave  
 b17:	c3                   	ret    

00000b18 <BB_pop>:

void* BB_pop(struct BB* bb)
{
 b18:	55                   	push   %ebp
 b19:	89 e5                	mov    %esp,%ebp
 b1b:	83 ec 28             	sub    $0x28,%esp
  
  void* element_to_pop;
  semaphore_down(bb->full);
 b1e:	8b 45 08             	mov    0x8(%ebp),%eax
 b21:	8b 40 0c             	mov    0xc(%eax),%eax
 b24:	89 04 24             	mov    %eax,(%esp)
 b27:	e8 bb fd ff ff       	call   8e7 <semaphore_down>
  binary_semaphore_down(bb->mutex);
 b2c:	8b 45 08             	mov    0x8(%ebp),%eax
 b2f:	8b 40 04             	mov    0x4(%eax),%eax
 b32:	89 04 24             	mov    %eax,(%esp)
 b35:	e8 5e f8 ff ff       	call   398 <binary_semaphore_down>
  element_to_pop = bb->pointer_to_elements[0];
 b3a:	8b 45 08             	mov    0x8(%ebp),%eax
 b3d:	8b 40 1c             	mov    0x1c(%eax),%eax
 b40:	8b 00                	mov    (%eax),%eax
 b42:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  if(!element_to_pop){
 b45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b49:	75 14                	jne    b5f <BB_pop+0x47>
  printf(1,"we have uninitialize element\n");
 b4b:	c7 44 24 04 c8 0c 00 	movl   $0xcc8,0x4(%esp)
 b52:	00 
 b53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 b5a:	e8 20 f9 ff ff       	call   47f <printf>
  }
  
  // shift left all elements at the array
  int i;
  for(i = 0; i < bb->count ; i++){
 b5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 b66:	eb 4b                	jmp    bb3 <BB_pop+0x9b>
    if(i != (bb->count -1)){
 b68:	8b 45 08             	mov    0x8(%ebp),%eax
 b6b:	8b 40 10             	mov    0x10(%eax),%eax
 b6e:	83 e8 01             	sub    $0x1,%eax
 b71:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 b74:	74 25                	je     b9b <BB_pop+0x83>
      bb->pointer_to_elements[i] = bb->pointer_to_elements[i+1];
 b76:	8b 45 08             	mov    0x8(%ebp),%eax
 b79:	8b 40 1c             	mov    0x1c(%eax),%eax
 b7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
 b7f:	c1 e2 02             	shl    $0x2,%edx
 b82:	01 c2                	add    %eax,%edx
 b84:	8b 45 08             	mov    0x8(%ebp),%eax
 b87:	8b 40 1c             	mov    0x1c(%eax),%eax
 b8a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 b8d:	83 c1 01             	add    $0x1,%ecx
 b90:	c1 e1 02             	shl    $0x2,%ecx
 b93:	01 c8                	add    %ecx,%eax
 b95:	8b 00                	mov    (%eax),%eax
 b97:	89 02                	mov    %eax,(%edx)
 b99:	eb 14                	jmp    baf <BB_pop+0x97>
    }else{
      bb->pointer_to_elements[i] = 0;
 b9b:	8b 45 08             	mov    0x8(%ebp),%eax
 b9e:	8b 40 1c             	mov    0x1c(%eax),%eax
 ba1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 ba4:	c1 e2 02             	shl    $0x2,%edx
 ba7:	01 d0                	add    %edx,%eax
 ba9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  printf(1,"we have uninitialize element\n");
  }
  
  // shift left all elements at the array
  int i;
  for(i = 0; i < bb->count ; i++){
 baf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 bb3:	8b 45 08             	mov    0x8(%ebp),%eax
 bb6:	8b 40 10             	mov    0x10(%eax),%eax
 bb9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 bbc:	7f aa                	jg     b68 <BB_pop+0x50>
     }
     
  }
  
  
  bb->count--;
 bbe:	8b 45 08             	mov    0x8(%ebp),%eax
 bc1:	8b 40 10             	mov    0x10(%eax),%eax
 bc4:	8d 50 ff             	lea    -0x1(%eax),%edx
 bc7:	8b 45 08             	mov    0x8(%ebp),%eax
 bca:	89 50 10             	mov    %edx,0x10(%eax)
  
  binary_semaphore_up(bb->mutex);
 bcd:	8b 45 08             	mov    0x8(%ebp),%eax
 bd0:	8b 40 04             	mov    0x4(%eax),%eax
 bd3:	89 04 24             	mov    %eax,(%esp)
 bd6:	e8 c5 f7 ff ff       	call   3a0 <binary_semaphore_up>
  semaphore_up(bb->empty);
 bdb:	8b 45 08             	mov    0x8(%ebp),%eax
 bde:	8b 40 08             	mov    0x8(%eax),%eax
 be1:	89 04 24             	mov    %eax,(%esp)
 be4:	e8 55 fd ff ff       	call   93e <semaphore_up>
  
  return element_to_pop;
 be9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 bec:	c9                   	leave  
 bed:	c3                   	ret    

00000bee <BB_free>:

void BB_free(struct BB* bb){
 bee:	55                   	push   %ebp
 bef:	89 e5                	mov    %esp,%ebp
 bf1:	83 ec 18             	sub    $0x18,%esp
  semaphore_free(bb->empty);
 bf4:	8b 45 08             	mov    0x8(%ebp),%eax
 bf7:	8b 40 08             	mov    0x8(%eax),%eax
 bfa:	89 04 24             	mov    %eax,(%esp)
 bfd:	e8 86 fd ff ff       	call   988 <semaphore_free>
  semaphore_free(bb->full);
 c02:	8b 45 08             	mov    0x8(%ebp),%eax
 c05:	8b 40 0c             	mov    0xc(%eax),%eax
 c08:	89 04 24             	mov    %eax,(%esp)
 c0b:	e8 78 fd ff ff       	call   988 <semaphore_free>
  free(bb->pointer_to_elements);
 c10:	8b 45 08             	mov    0x8(%ebp),%eax
 c13:	8b 40 1c             	mov    0x1c(%eax),%eax
 c16:	89 04 24             	mov    %eax,(%esp)
 c19:	e8 16 fa ff ff       	call   634 <free>
  free(bb);
 c1e:	8b 45 08             	mov    0x8(%ebp),%eax
 c21:	89 04 24             	mov    %eax,(%esp)
 c24:	e8 0b fa ff ff       	call   634 <free>
}
 c29:	c9                   	leave  
 c2a:	c3                   	ret    
