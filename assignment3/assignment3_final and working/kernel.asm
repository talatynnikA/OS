
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 e6 10 80       	mov    $0x8010e6c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 d7 33 10 80       	mov    $0x801033d7,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 c0 97 10 	movl   $0x801097c0,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 c0 e6 10 80 	movl   $0x8010e6c0,(%esp)
80100049:	e8 94 5f 00 00       	call   80105fe2 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 f0 fb 10 80 e4 	movl   $0x8010fbe4,0x8010fbf0
80100055:	fb 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 f4 fb 10 80 e4 	movl   $0x8010fbe4,0x8010fbf4
8010005f:	fb 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 f4 e6 10 80 	movl   $0x8010e6f4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 f4 fb 10 80    	mov    0x8010fbf4,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c e4 fb 10 80 	movl   $0x8010fbe4,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 f4 fb 10 80       	mov    0x8010fbf4,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 f4 fb 10 80       	mov    %eax,0x8010fbf4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 e4 fb 10 80 	cmpl   $0x8010fbe4,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 c0 e6 10 80 	movl   $0x8010e6c0,(%esp)
801000bd:	e8 41 5f 00 00       	call   80106003 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 f4 fb 10 80       	mov    0x8010fbf4,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 c0 e6 10 80 	movl   $0x8010e6c0,(%esp)
80100104:	e8 72 5f 00 00       	call   8010607b <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 c0 e6 10 	movl   $0x8010e6c0,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 35 48 00 00       	call   80104959 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 e4 fb 10 80 	cmpl   $0x8010fbe4,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 f0 fb 10 80       	mov    0x8010fbf0,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 c0 e6 10 80 	movl   $0x8010e6c0,(%esp)
8010017c:	e8 fa 5e 00 00       	call   8010607b <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 e4 fb 10 80 	cmpl   $0x8010fbe4,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 c7 97 10 80 	movl   $0x801097c7,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 dd 25 00 00       	call   801027b5 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 d8 97 10 80 	movl   $0x801097d8,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 a0 25 00 00       	call   801027b5 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 df 97 10 80 	movl   $0x801097df,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 c0 e6 10 80 	movl   $0x8010e6c0,(%esp)
8010023c:	e8 c2 5d 00 00       	call   80106003 <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 f4 fb 10 80    	mov    0x8010fbf4,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c e4 fb 10 80 	movl   $0x8010fbe4,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 f4 fb 10 80       	mov    0x8010fbf4,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 f4 fb 10 80       	mov    %eax,0x8010fbf4

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 f6 47 00 00       	call   80104a98 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 c0 e6 10 80 	movl   $0x8010e6c0,(%esp)
801002a9:	e8 cd 5d 00 00       	call   8010607b <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 b0 10 80 	movzbl -0x7fef4ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 bb 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 54 d6 10 80       	mov    0x8010d654,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
801003bc:	e8 42 5c 00 00       	call   80106003 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 e6 97 10 80 	movl   $0x801097e6,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 59 03 00 00       	call   80100750 <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec ef 97 10 80 	movl   $0x801097ef,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 87 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
80100536:	e8 40 5b 00 00       	call   8010607b <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 54 d6 10 80 00 	movl   $0x0,0x8010d654
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 f6 97 10 80 	movl   $0x801097f6,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 05 98 10 80 	movl   $0x80109805,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 33 5b 00 00       	call   801060ca <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 07 98 10 80 	movl   $0x80109807,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 00 d6 10 80 01 	movl   $0x1,0x8010d600
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 30                	jne    80100658 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 32                	jmp    8010068a <cgaputc+0xbd>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 23                	jle    8010068a <cgaputc+0xbd>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 1d                	jmp    8010068a <cgaputc+0xbd>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066d:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100672:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100675:	01 d2                	add    %edx,%edx
80100677:	01 c2                	add    %eax,%edx
80100679:	8b 45 08             	mov    0x8(%ebp),%eax
8010067c:	66 25 ff 00          	and    $0xff,%ax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)
80100686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x119>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 82 5c 00 00       	call   80106339 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	01 c0                	add    %eax,%eax
801006c5:	8b 15 00 b0 10 80    	mov    0x8010b000,%edx
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 ca                	add    %ecx,%edx
801006d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 14 24             	mov    %edx,(%esp)
801006e1:	e8 80 5b 00 00       	call   80106266 <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 e0 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 c7 fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 b3 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 9d fb ff ff       	call   801002da <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 00 d6 10 80       	mov    0x8010d600,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 94 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 b6 76 00 00       	call   80107e31 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 aa 76 00 00       	call   80107e31 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 9e 76 00 00       	call   80107e31 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 91 76 00 00       	call   80107e31 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 22 fe ff ff       	call   801005cd <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 00 fe 10 80 	movl   $0x8010fe00,(%esp)
801007ba:	e8 44 58 00 00       	call   80106003 <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 41 01 00 00       	jmp    80100905 <consoleintr+0x158>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 68                	je     8010083e <consoleintr+0x91>
801007d6:	e9 94 00 00 00       	jmp    8010086f <consoleintr+0xc2>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 59                	je     8010083e <consoleintr+0x91>
801007e5:	e9 85 00 00 00       	jmp    8010086f <consoleintr+0xc2>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 66 43 00 00       	call   80104b55 <procdump>
      break;
801007ef:	e9 11 01 00 00       	jmp    80100905 <consoleintr+0x158>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 bc fe 10 80       	mov    0x8010febc,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 bc fe 10 80       	mov    %eax,0x8010febc
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 bc fe 10 80    	mov    0x8010febc,%edx
80100816:	a1 b8 fe 10 80       	mov    0x8010feb8,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	0f 84 db 00 00 00    	je     801008fe <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100823:	a1 bc fe 10 80       	mov    0x8010febc,%eax
80100828:	83 e8 01             	sub    $0x1,%eax
8010082b:	83 e0 7f             	and    $0x7f,%eax
8010082e:	0f b6 80 34 fe 10 80 	movzbl -0x7fef01cc(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100835:	3c 0a                	cmp    $0xa,%al
80100837:	75 bb                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100839:	e9 c0 00 00 00       	jmp    801008fe <consoleintr+0x151>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083e:	8b 15 bc fe 10 80    	mov    0x8010febc,%edx
80100844:	a1 b8 fe 10 80       	mov    0x8010feb8,%eax
80100849:	39 c2                	cmp    %eax,%edx
8010084b:	0f 84 b0 00 00 00    	je     80100901 <consoleintr+0x154>
        input.e--;
80100851:	a1 bc fe 10 80       	mov    0x8010febc,%eax
80100856:	83 e8 01             	sub    $0x1,%eax
80100859:	a3 bc fe 10 80       	mov    %eax,0x8010febc
        consputc(BACKSPACE);
8010085e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100865:	e8 e6 fe ff ff       	call   80100750 <consputc>
      }
      break;
8010086a:	e9 92 00 00 00       	jmp    80100901 <consoleintr+0x154>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100873:	0f 84 8b 00 00 00    	je     80100904 <consoleintr+0x157>
80100879:	8b 15 bc fe 10 80    	mov    0x8010febc,%edx
8010087f:	a1 b4 fe 10 80       	mov    0x8010feb4,%eax
80100884:	89 d1                	mov    %edx,%ecx
80100886:	29 c1                	sub    %eax,%ecx
80100888:	89 c8                	mov    %ecx,%eax
8010088a:	83 f8 7f             	cmp    $0x7f,%eax
8010088d:	77 75                	ja     80100904 <consoleintr+0x157>
        c = (c == '\r') ? '\n' : c;
8010088f:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
80100893:	74 05                	je     8010089a <consoleintr+0xed>
80100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100898:	eb 05                	jmp    8010089f <consoleintr+0xf2>
8010089a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008a2:	a1 bc fe 10 80       	mov    0x8010febc,%eax
801008a7:	89 c1                	mov    %eax,%ecx
801008a9:	83 e1 7f             	and    $0x7f,%ecx
801008ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008af:	88 91 34 fe 10 80    	mov    %dl,-0x7fef01cc(%ecx)
801008b5:	83 c0 01             	add    $0x1,%eax
801008b8:	a3 bc fe 10 80       	mov    %eax,0x8010febc
        consputc(c);
801008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008c0:	89 04 24             	mov    %eax,(%esp)
801008c3:	e8 88 fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c8:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008cc:	74 18                	je     801008e6 <consoleintr+0x139>
801008ce:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008d2:	74 12                	je     801008e6 <consoleintr+0x139>
801008d4:	a1 bc fe 10 80       	mov    0x8010febc,%eax
801008d9:	8b 15 b4 fe 10 80    	mov    0x8010feb4,%edx
801008df:	83 ea 80             	sub    $0xffffff80,%edx
801008e2:	39 d0                	cmp    %edx,%eax
801008e4:	75 1e                	jne    80100904 <consoleintr+0x157>
          input.w = input.e;
801008e6:	a1 bc fe 10 80       	mov    0x8010febc,%eax
801008eb:	a3 b8 fe 10 80       	mov    %eax,0x8010feb8
          wakeup(&input.r);
801008f0:	c7 04 24 b4 fe 10 80 	movl   $0x8010feb4,(%esp)
801008f7:	e8 9c 41 00 00       	call   80104a98 <wakeup>
        }
      }
      break;
801008fc:	eb 06                	jmp    80100904 <consoleintr+0x157>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008fe:	90                   	nop
801008ff:	eb 04                	jmp    80100905 <consoleintr+0x158>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100901:	90                   	nop
80100902:	eb 01                	jmp    80100905 <consoleintr+0x158>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100904:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100905:	8b 45 08             	mov    0x8(%ebp),%eax
80100908:	ff d0                	call   *%eax
8010090a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010090d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100911:	0f 89 ad fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100917:	c7 04 24 00 fe 10 80 	movl   $0x8010fe00,(%esp)
8010091e:	e8 58 57 00 00       	call   8010607b <release>
}
80100923:	c9                   	leave  
80100924:	c3                   	ret    

80100925 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100925:	55                   	push   %ebp
80100926:	89 e5                	mov    %esp,%ebp
80100928:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
8010092b:	8b 45 08             	mov    0x8(%ebp),%eax
8010092e:	89 04 24             	mov    %eax,(%esp)
80100931:	e8 80 10 00 00       	call   801019b6 <iunlock>
  target = n;
80100936:	8b 45 10             	mov    0x10(%ebp),%eax
80100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010093c:	c7 04 24 00 fe 10 80 	movl   $0x8010fe00,(%esp)
80100943:	e8 bb 56 00 00       	call   80106003 <acquire>
  while(n > 0){
80100948:	e9 a8 00 00 00       	jmp    801009f5 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010094d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100953:	8b 40 24             	mov    0x24(%eax),%eax
80100956:	85 c0                	test   %eax,%eax
80100958:	74 21                	je     8010097b <consoleread+0x56>
        release(&input.lock);
8010095a:	c7 04 24 00 fe 10 80 	movl   $0x8010fe00,(%esp)
80100961:	e8 15 57 00 00       	call   8010607b <release>
        ilock(ip);
80100966:	8b 45 08             	mov    0x8(%ebp),%eax
80100969:	89 04 24             	mov    %eax,(%esp)
8010096c:	e8 f7 0e 00 00       	call   80101868 <ilock>
        return -1;
80100971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100976:	e9 a9 00 00 00       	jmp    80100a24 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010097b:	c7 44 24 04 00 fe 10 	movl   $0x8010fe00,0x4(%esp)
80100982:	80 
80100983:	c7 04 24 b4 fe 10 80 	movl   $0x8010feb4,(%esp)
8010098a:	e8 ca 3f 00 00       	call   80104959 <sleep>
8010098f:	eb 01                	jmp    80100992 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100991:	90                   	nop
80100992:	8b 15 b4 fe 10 80    	mov    0x8010feb4,%edx
80100998:	a1 b8 fe 10 80       	mov    0x8010feb8,%eax
8010099d:	39 c2                	cmp    %eax,%edx
8010099f:	74 ac                	je     8010094d <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009a1:	a1 b4 fe 10 80       	mov    0x8010feb4,%eax
801009a6:	89 c2                	mov    %eax,%edx
801009a8:	83 e2 7f             	and    $0x7f,%edx
801009ab:	0f b6 92 34 fe 10 80 	movzbl -0x7fef01cc(%edx),%edx
801009b2:	0f be d2             	movsbl %dl,%edx
801009b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009b8:	83 c0 01             	add    $0x1,%eax
801009bb:	a3 b4 fe 10 80       	mov    %eax,0x8010feb4
    if(c == C('D')){  // EOF
801009c0:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009c4:	75 17                	jne    801009dd <consoleread+0xb8>
      if(n < target){
801009c6:	8b 45 10             	mov    0x10(%ebp),%eax
801009c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009cc:	73 2f                	jae    801009fd <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009ce:	a1 b4 fe 10 80       	mov    0x8010feb4,%eax
801009d3:	83 e8 01             	sub    $0x1,%eax
801009d6:	a3 b4 fe 10 80       	mov    %eax,0x8010feb4
      }
      break;
801009db:	eb 20                	jmp    801009fd <consoleread+0xd8>
    }
    *dst++ = c;
801009dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009e0:	89 c2                	mov    %eax,%edx
801009e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801009e5:	88 10                	mov    %dl,(%eax)
801009e7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
801009eb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009ef:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009f3:	74 0b                	je     80100a00 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f9:	7f 96                	jg     80100991 <consoleread+0x6c>
801009fb:	eb 04                	jmp    80100a01 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
801009fd:	90                   	nop
801009fe:	eb 01                	jmp    80100a01 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a00:	90                   	nop
  }
  release(&input.lock);
80100a01:	c7 04 24 00 fe 10 80 	movl   $0x8010fe00,(%esp)
80100a08:	e8 6e 56 00 00       	call   8010607b <release>
  ilock(ip);
80100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a10:	89 04 24             	mov    %eax,(%esp)
80100a13:	e8 50 0e 00 00       	call   80101868 <ilock>

  return target - n;
80100a18:	8b 45 10             	mov    0x10(%ebp),%eax
80100a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a1e:	89 d1                	mov    %edx,%ecx
80100a20:	29 c1                	sub    %eax,%ecx
80100a22:	89 c8                	mov    %ecx,%eax
}
80100a24:	c9                   	leave  
80100a25:	c3                   	ret    

80100a26 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a26:	55                   	push   %ebp
80100a27:	89 e5                	mov    %esp,%ebp
80100a29:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2f:	89 04 24             	mov    %eax,(%esp)
80100a32:	e8 7f 0f 00 00       	call   801019b6 <iunlock>
  acquire(&cons.lock);
80100a37:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
80100a3e:	e8 c0 55 00 00       	call   80106003 <acquire>
  for(i = 0; i < n; i++)
80100a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a4a:	eb 1d                	jmp    80100a69 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a4f:	03 45 0c             	add    0xc(%ebp),%eax
80100a52:	0f b6 00             	movzbl (%eax),%eax
80100a55:	0f be c0             	movsbl %al,%eax
80100a58:	25 ff 00 00 00       	and    $0xff,%eax
80100a5d:	89 04 24             	mov    %eax,(%esp)
80100a60:	e8 eb fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a6c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a6f:	7c db                	jl     80100a4c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a71:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
80100a78:	e8 fe 55 00 00       	call   8010607b <release>
  ilock(ip);
80100a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 e0 0d 00 00       	call   80101868 <ilock>

  return n;
80100a88:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a8b:	c9                   	leave  
80100a8c:	c3                   	ret    

80100a8d <consoleinit>:

void
consoleinit(void)
{
80100a8d:	55                   	push   %ebp
80100a8e:	89 e5                	mov    %esp,%ebp
80100a90:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a93:	c7 44 24 04 0b 98 10 	movl   $0x8010980b,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 20 d6 10 80 	movl   $0x8010d620,(%esp)
80100aa2:	e8 3b 55 00 00       	call   80105fe2 <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 13 98 10 	movl   $0x80109813,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 00 fe 10 80 	movl   $0x8010fe00,(%esp)
80100ab6:	e8 27 55 00 00       	call   80105fe2 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abb:	c7 05 6c 08 11 80 26 	movl   $0x80100a26,0x8011086c
80100ac2:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac5:	c7 05 68 08 11 80 25 	movl   $0x80100925,0x80110868
80100acc:	09 10 80 
  cons.locking = 1;
80100acf:	c7 05 54 d6 10 80 01 	movl   $0x1,0x8010d654
80100ad6:	00 00 00 

  picenable(IRQ_KBD);
80100ad9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae0:	e8 ac 2f 00 00       	call   80103a91 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aec:	00 
80100aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af4:	e8 71 1e 00 00       	call   8010296a <ioapicenable>
}
80100af9:	c9                   	leave  
80100afa:	c3                   	ret    
	...

80100afc <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100afc:	55                   	push   %ebp
80100afd:	89 e5                	mov    %esp,%ebp
80100aff:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100b05:	8b 45 08             	mov    0x8(%ebp),%eax
80100b08:	89 04 24             	mov    %eax,(%esp)
80100b0b:	e8 fa 18 00 00       	call   8010240a <namei>
80100b10:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b13:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b17:	75 0a                	jne    80100b23 <exec+0x27>
    return -1;
80100b19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b1e:	e9 da 03 00 00       	jmp    80100efd <exec+0x401>
  ilock(ip);
80100b23:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b26:	89 04 24             	mov    %eax,(%esp)
80100b29:	e8 3a 0d 00 00       	call   80101868 <ilock>
  pgdir = 0;
80100b2e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b35:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b3c:	00 
80100b3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b44:	00 
80100b45:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b4f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b52:	89 04 24             	mov    %eax,(%esp)
80100b55:	e8 04 12 00 00       	call   80101d5e <readi>
80100b5a:	83 f8 33             	cmp    $0x33,%eax
80100b5d:	0f 86 54 03 00 00    	jbe    80100eb7 <exec+0x3bb>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b63:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b69:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b6e:	0f 85 46 03 00 00    	jne    80100eba <exec+0x3be>
    goto bad;

  if((pgdir = setupkvm(kalloc)) == 0)
80100b74:	c7 04 24 f3 2a 10 80 	movl   $0x80102af3,(%esp)
80100b7b:	e8 f5 83 00 00       	call   80108f75 <setupkvm>
80100b80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b83:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b87:	0f 84 30 03 00 00    	je     80100ebd <exec+0x3c1>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b8d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b94:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b9b:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ba1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ba4:	e9 c5 00 00 00       	jmp    80100c6e <exec+0x172>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ba9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bac:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bb3:	00 
80100bb4:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bb8:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bc2:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bc5:	89 04 24             	mov    %eax,(%esp)
80100bc8:	e8 91 11 00 00       	call   80101d5e <readi>
80100bcd:	83 f8 20             	cmp    $0x20,%eax
80100bd0:	0f 85 ea 02 00 00    	jne    80100ec0 <exec+0x3c4>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100bd6:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bdc:	83 f8 01             	cmp    $0x1,%eax
80100bdf:	75 7f                	jne    80100c60 <exec+0x164>
      continue;
    if(ph.memsz < ph.filesz)
80100be1:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100be7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bed:	39 c2                	cmp    %eax,%edx
80100bef:	0f 82 ce 02 00 00    	jb     80100ec3 <exec+0x3c7>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf5:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfb:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c01:	01 d0                	add    %edx,%eax
80100c03:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c11:	89 04 24             	mov    %eax,(%esp)
80100c14:	e8 2e 87 00 00       	call   80109347 <allocuvm>
80100c19:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c20:	0f 84 a0 02 00 00    	je     80100ec6 <exec+0x3ca>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c26:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c2c:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c32:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c38:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c40:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c43:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c47:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c4e:	89 04 24             	mov    %eax,(%esp)
80100c51:	e8 02 86 00 00       	call   80109258 <loaduvm>
80100c56:	85 c0                	test   %eax,%eax
80100c58:	0f 88 6b 02 00 00    	js     80100ec9 <exec+0x3cd>
80100c5e:	eb 01                	jmp    80100c61 <exec+0x165>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c60:	90                   	nop
  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c61:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c65:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c68:	83 c0 20             	add    $0x20,%eax
80100c6b:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c6e:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c75:	0f b7 c0             	movzwl %ax,%eax
80100c78:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c7b:	0f 8f 28 ff ff ff    	jg     80100ba9 <exec+0xad>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c81:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c84:	89 04 24             	mov    %eax,(%esp)
80100c87:	e8 60 0e 00 00       	call   80101aec <iunlockput>
  ip = 0;
80100c8c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c96:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ca3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ca6:	05 00 20 00 00       	add    $0x2000,%eax
80100cab:	89 44 24 08          	mov    %eax,0x8(%esp)
80100caf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cb6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cb9:	89 04 24             	mov    %eax,(%esp)
80100cbc:	e8 86 86 00 00       	call   80109347 <allocuvm>
80100cc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cc4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cc8:	0f 84 fe 01 00 00    	je     80100ecc <exec+0x3d0>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cce:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd1:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cda:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cdd:	89 04 24             	mov    %eax,(%esp)
80100ce0:	e8 7a 88 00 00       	call   8010955f <clearpteu>
  sp = sz;
80100ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ceb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cf2:	e9 81 00 00 00       	jmp    80100d78 <exec+0x27c>
    if(argc >= MAXARG)
80100cf7:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100cfb:	0f 87 ce 01 00 00    	ja     80100ecf <exec+0x3d3>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d04:	c1 e0 02             	shl    $0x2,%eax
80100d07:	03 45 0c             	add    0xc(%ebp),%eax
80100d0a:	8b 00                	mov    (%eax),%eax
80100d0c:	89 04 24             	mov    %eax,(%esp)
80100d0f:	e8 d0 57 00 00       	call   801064e4 <strlen>
80100d14:	f7 d0                	not    %eax
80100d16:	03 45 dc             	add    -0x24(%ebp),%eax
80100d19:	83 e0 fc             	and    $0xfffffffc,%eax
80100d1c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d22:	c1 e0 02             	shl    $0x2,%eax
80100d25:	03 45 0c             	add    0xc(%ebp),%eax
80100d28:	8b 00                	mov    (%eax),%eax
80100d2a:	89 04 24             	mov    %eax,(%esp)
80100d2d:	e8 b2 57 00 00       	call   801064e4 <strlen>
80100d32:	83 c0 01             	add    $0x1,%eax
80100d35:	89 c2                	mov    %eax,%edx
80100d37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d3a:	c1 e0 02             	shl    $0x2,%eax
80100d3d:	03 45 0c             	add    0xc(%ebp),%eax
80100d40:	8b 00                	mov    (%eax),%eax
80100d42:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d46:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d54:	89 04 24             	mov    %eax,(%esp)
80100d57:	e8 b7 89 00 00       	call   80109713 <copyout>
80100d5c:	85 c0                	test   %eax,%eax
80100d5e:	0f 88 6e 01 00 00    	js     80100ed2 <exec+0x3d6>
      goto bad;
    ustack[3+argc] = sp;
80100d64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d67:	8d 50 03             	lea    0x3(%eax),%edx
80100d6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d6d:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d74:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d7b:	c1 e0 02             	shl    $0x2,%eax
80100d7e:	03 45 0c             	add    0xc(%ebp),%eax
80100d81:	8b 00                	mov    (%eax),%eax
80100d83:	85 c0                	test   %eax,%eax
80100d85:	0f 85 6c ff ff ff    	jne    80100cf7 <exec+0x1fb>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100d8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8e:	83 c0 03             	add    $0x3,%eax
80100d91:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100d98:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100d9c:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100da3:	ff ff ff 
  ustack[1] = argc;
80100da6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da9:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100daf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db2:	83 c0 01             	add    $0x1,%eax
80100db5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dbf:	29 d0                	sub    %edx,%eax
80100dc1:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100dc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dca:	83 c0 04             	add    $0x4,%eax
80100dcd:	c1 e0 02             	shl    $0x2,%eax
80100dd0:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100dd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd6:	83 c0 04             	add    $0x4,%eax
80100dd9:	c1 e0 02             	shl    $0x2,%eax
80100ddc:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100de0:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100de6:	89 44 24 08          	mov    %eax,0x8(%esp)
80100dea:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ded:	89 44 24 04          	mov    %eax,0x4(%esp)
80100df1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100df4:	89 04 24             	mov    %eax,(%esp)
80100df7:	e8 17 89 00 00       	call   80109713 <copyout>
80100dfc:	85 c0                	test   %eax,%eax
80100dfe:	0f 88 d1 00 00 00    	js     80100ed5 <exec+0x3d9>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e04:	8b 45 08             	mov    0x8(%ebp),%eax
80100e07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e10:	eb 17                	jmp    80100e29 <exec+0x32d>
    if(*s == '/')
80100e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e15:	0f b6 00             	movzbl (%eax),%eax
80100e18:	3c 2f                	cmp    $0x2f,%al
80100e1a:	75 09                	jne    80100e25 <exec+0x329>
      last = s+1;
80100e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e1f:	83 c0 01             	add    $0x1,%eax
80100e22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e2c:	0f b6 00             	movzbl (%eax),%eax
80100e2f:	84 c0                	test   %al,%al
80100e31:	75 df                	jne    80100e12 <exec+0x316>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e39:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e3c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e43:	00 
80100e44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e47:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e4b:	89 14 24             	mov    %edx,(%esp)
80100e4e:	e8 43 56 00 00       	call   80106496 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e59:	8b 40 04             	mov    0x4(%eax),%eax
80100e5c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e65:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e68:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e71:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e74:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7c:	8b 40 18             	mov    0x18(%eax),%eax
80100e7f:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100e85:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100e88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e8e:	8b 40 18             	mov    0x18(%eax),%eax
80100e91:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100e94:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100e97:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e9d:	89 04 24             	mov    %eax,(%esp)
80100ea0:	e8 c1 81 00 00       	call   80109066 <switchuvm>
  freevm(oldpgdir);
80100ea5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ea8:	89 04 24             	mov    %eax,(%esp)
80100eab:	e8 21 86 00 00       	call   801094d1 <freevm>
  return 0;
80100eb0:	b8 00 00 00 00       	mov    $0x0,%eax
80100eb5:	eb 46                	jmp    80100efd <exec+0x401>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100eb7:	90                   	nop
80100eb8:	eb 1c                	jmp    80100ed6 <exec+0x3da>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100eba:	90                   	nop
80100ebb:	eb 19                	jmp    80100ed6 <exec+0x3da>

  if((pgdir = setupkvm(kalloc)) == 0)
    goto bad;
80100ebd:	90                   	nop
80100ebe:	eb 16                	jmp    80100ed6 <exec+0x3da>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100ec0:	90                   	nop
80100ec1:	eb 13                	jmp    80100ed6 <exec+0x3da>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100ec3:	90                   	nop
80100ec4:	eb 10                	jmp    80100ed6 <exec+0x3da>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100ec6:	90                   	nop
80100ec7:	eb 0d                	jmp    80100ed6 <exec+0x3da>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100ec9:	90                   	nop
80100eca:	eb 0a                	jmp    80100ed6 <exec+0x3da>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100ecc:	90                   	nop
80100ecd:	eb 07                	jmp    80100ed6 <exec+0x3da>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100ecf:	90                   	nop
80100ed0:	eb 04                	jmp    80100ed6 <exec+0x3da>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100ed2:	90                   	nop
80100ed3:	eb 01                	jmp    80100ed6 <exec+0x3da>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100ed5:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100ed6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100eda:	74 0b                	je     80100ee7 <exec+0x3eb>
    freevm(pgdir);
80100edc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100edf:	89 04 24             	mov    %eax,(%esp)
80100ee2:	e8 ea 85 00 00       	call   801094d1 <freevm>
  if(ip)
80100ee7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100eeb:	74 0b                	je     80100ef8 <exec+0x3fc>
    iunlockput(ip);
80100eed:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ef0:	89 04 24             	mov    %eax,(%esp)
80100ef3:	e8 f4 0b 00 00       	call   80101aec <iunlockput>
  return -1;
80100ef8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100efd:	c9                   	leave  
80100efe:	c3                   	ret    
	...

80100f00 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f00:	55                   	push   %ebp
80100f01:	89 e5                	mov    %esp,%ebp
80100f03:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f06:	c7 44 24 04 19 98 10 	movl   $0x80109819,0x4(%esp)
80100f0d:	80 
80100f0e:	c7 04 24 c0 fe 10 80 	movl   $0x8010fec0,(%esp)
80100f15:	e8 c8 50 00 00       	call   80105fe2 <initlock>
}
80100f1a:	c9                   	leave  
80100f1b:	c3                   	ret    

80100f1c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f1c:	55                   	push   %ebp
80100f1d:	89 e5                	mov    %esp,%ebp
80100f1f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f22:	c7 04 24 c0 fe 10 80 	movl   $0x8010fec0,(%esp)
80100f29:	e8 d5 50 00 00       	call   80106003 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f2e:	c7 45 f4 f4 fe 10 80 	movl   $0x8010fef4,-0xc(%ebp)
80100f35:	eb 29                	jmp    80100f60 <filealloc+0x44>
    if(f->ref == 0){
80100f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f3a:	8b 40 04             	mov    0x4(%eax),%eax
80100f3d:	85 c0                	test   %eax,%eax
80100f3f:	75 1b                	jne    80100f5c <filealloc+0x40>
      f->ref = 1;
80100f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f44:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f4b:	c7 04 24 c0 fe 10 80 	movl   $0x8010fec0,(%esp)
80100f52:	e8 24 51 00 00       	call   8010607b <release>
      return f;
80100f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5a:	eb 1e                	jmp    80100f7a <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f5c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f60:	81 7d f4 54 08 11 80 	cmpl   $0x80110854,-0xc(%ebp)
80100f67:	72 ce                	jb     80100f37 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f69:	c7 04 24 c0 fe 10 80 	movl   $0x8010fec0,(%esp)
80100f70:	e8 06 51 00 00       	call   8010607b <release>
  return 0;
80100f75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f7a:	c9                   	leave  
80100f7b:	c3                   	ret    

80100f7c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f7c:	55                   	push   %ebp
80100f7d:	89 e5                	mov    %esp,%ebp
80100f7f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f82:	c7 04 24 c0 fe 10 80 	movl   $0x8010fec0,(%esp)
80100f89:	e8 75 50 00 00       	call   80106003 <acquire>
  if(f->ref < 1)
80100f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80100f91:	8b 40 04             	mov    0x4(%eax),%eax
80100f94:	85 c0                	test   %eax,%eax
80100f96:	7f 0c                	jg     80100fa4 <filedup+0x28>
    panic("filedup");
80100f98:	c7 04 24 20 98 10 80 	movl   $0x80109820,(%esp)
80100f9f:	e8 99 f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa7:	8b 40 04             	mov    0x4(%eax),%eax
80100faa:	8d 50 01             	lea    0x1(%eax),%edx
80100fad:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb0:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fb3:	c7 04 24 c0 fe 10 80 	movl   $0x8010fec0,(%esp)
80100fba:	e8 bc 50 00 00       	call   8010607b <release>
  return f;
80100fbf:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fc2:	c9                   	leave  
80100fc3:	c3                   	ret    

80100fc4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fc4:	55                   	push   %ebp
80100fc5:	89 e5                	mov    %esp,%ebp
80100fc7:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fca:	c7 04 24 c0 fe 10 80 	movl   $0x8010fec0,(%esp)
80100fd1:	e8 2d 50 00 00       	call   80106003 <acquire>
  if(f->ref < 1)
80100fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd9:	8b 40 04             	mov    0x4(%eax),%eax
80100fdc:	85 c0                	test   %eax,%eax
80100fde:	7f 0c                	jg     80100fec <fileclose+0x28>
    panic("fileclose");
80100fe0:	c7 04 24 28 98 10 80 	movl   $0x80109828,(%esp)
80100fe7:	e8 51 f5 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80100fec:	8b 45 08             	mov    0x8(%ebp),%eax
80100fef:	8b 40 04             	mov    0x4(%eax),%eax
80100ff2:	8d 50 ff             	lea    -0x1(%eax),%edx
80100ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff8:	89 50 04             	mov    %edx,0x4(%eax)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7e 11                	jle    80101016 <fileclose+0x52>
    release(&ftable.lock);
80101005:	c7 04 24 c0 fe 10 80 	movl   $0x8010fec0,(%esp)
8010100c:	e8 6a 50 00 00       	call   8010607b <release>
    return;
80101011:	e9 82 00 00 00       	jmp    80101098 <fileclose+0xd4>
  }
  ff = *f;
80101016:	8b 45 08             	mov    0x8(%ebp),%eax
80101019:	8b 10                	mov    (%eax),%edx
8010101b:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010101e:	8b 50 04             	mov    0x4(%eax),%edx
80101021:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101024:	8b 50 08             	mov    0x8(%eax),%edx
80101027:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010102a:	8b 50 0c             	mov    0xc(%eax),%edx
8010102d:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101030:	8b 50 10             	mov    0x10(%eax),%edx
80101033:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101036:	8b 40 14             	mov    0x14(%eax),%eax
80101039:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
8010103c:	8b 45 08             	mov    0x8(%ebp),%eax
8010103f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101046:	8b 45 08             	mov    0x8(%ebp),%eax
80101049:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010104f:	c7 04 24 c0 fe 10 80 	movl   $0x8010fec0,(%esp)
80101056:	e8 20 50 00 00       	call   8010607b <release>
  
  if(ff.type == FD_PIPE)
8010105b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010105e:	83 f8 01             	cmp    $0x1,%eax
80101061:	75 18                	jne    8010107b <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101063:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101067:	0f be d0             	movsbl %al,%edx
8010106a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010106d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101071:	89 04 24             	mov    %eax,(%esp)
80101074:	e8 d2 2c 00 00       	call   80103d4b <pipeclose>
80101079:	eb 1d                	jmp    80101098 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010107b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010107e:	83 f8 02             	cmp    $0x2,%eax
80101081:	75 15                	jne    80101098 <fileclose+0xd4>
    begin_trans();
80101083:	e8 95 21 00 00       	call   8010321d <begin_trans>
    iput(ff.ip);
80101088:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010108b:	89 04 24             	mov    %eax,(%esp)
8010108e:	e8 88 09 00 00       	call   80101a1b <iput>
    commit_trans();
80101093:	e8 a8 21 00 00       	call   80103240 <commit_trans>
  }
}
80101098:	c9                   	leave  
80101099:	c3                   	ret    

8010109a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010109a:	55                   	push   %ebp
8010109b:	89 e5                	mov    %esp,%ebp
8010109d:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
801010a3:	8b 00                	mov    (%eax),%eax
801010a5:	83 f8 02             	cmp    $0x2,%eax
801010a8:	75 38                	jne    801010e2 <filestat+0x48>
    ilock(f->ip);
801010aa:	8b 45 08             	mov    0x8(%ebp),%eax
801010ad:	8b 40 10             	mov    0x10(%eax),%eax
801010b0:	89 04 24             	mov    %eax,(%esp)
801010b3:	e8 b0 07 00 00       	call   80101868 <ilock>
    stati(f->ip, st);
801010b8:	8b 45 08             	mov    0x8(%ebp),%eax
801010bb:	8b 40 10             	mov    0x10(%eax),%eax
801010be:	8b 55 0c             	mov    0xc(%ebp),%edx
801010c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801010c5:	89 04 24             	mov    %eax,(%esp)
801010c8:	e8 4c 0c 00 00       	call   80101d19 <stati>
    iunlock(f->ip);
801010cd:	8b 45 08             	mov    0x8(%ebp),%eax
801010d0:	8b 40 10             	mov    0x10(%eax),%eax
801010d3:	89 04 24             	mov    %eax,(%esp)
801010d6:	e8 db 08 00 00       	call   801019b6 <iunlock>
    return 0;
801010db:	b8 00 00 00 00       	mov    $0x0,%eax
801010e0:	eb 05                	jmp    801010e7 <filestat+0x4d>
  }
  return -1;
801010e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010e7:	c9                   	leave  
801010e8:	c3                   	ret    

801010e9 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010e9:	55                   	push   %ebp
801010ea:	89 e5                	mov    %esp,%ebp
801010ec:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010ef:	8b 45 08             	mov    0x8(%ebp),%eax
801010f2:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801010f6:	84 c0                	test   %al,%al
801010f8:	75 0a                	jne    80101104 <fileread+0x1b>
    return -1;
801010fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010ff:	e9 9f 00 00 00       	jmp    801011a3 <fileread+0xba>
  if(f->type == FD_PIPE)
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	8b 00                	mov    (%eax),%eax
80101109:	83 f8 01             	cmp    $0x1,%eax
8010110c:	75 1e                	jne    8010112c <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010110e:	8b 45 08             	mov    0x8(%ebp),%eax
80101111:	8b 40 0c             	mov    0xc(%eax),%eax
80101114:	8b 55 10             	mov    0x10(%ebp),%edx
80101117:	89 54 24 08          	mov    %edx,0x8(%esp)
8010111b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010111e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101122:	89 04 24             	mov    %eax,(%esp)
80101125:	e8 a3 2d 00 00       	call   80103ecd <piperead>
8010112a:	eb 77                	jmp    801011a3 <fileread+0xba>
  if(f->type == FD_INODE){
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 00                	mov    (%eax),%eax
80101131:	83 f8 02             	cmp    $0x2,%eax
80101134:	75 61                	jne    80101197 <fileread+0xae>
    ilock(f->ip);
80101136:	8b 45 08             	mov    0x8(%ebp),%eax
80101139:	8b 40 10             	mov    0x10(%eax),%eax
8010113c:	89 04 24             	mov    %eax,(%esp)
8010113f:	e8 24 07 00 00       	call   80101868 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101144:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101147:	8b 45 08             	mov    0x8(%ebp),%eax
8010114a:	8b 50 14             	mov    0x14(%eax),%edx
8010114d:	8b 45 08             	mov    0x8(%ebp),%eax
80101150:	8b 40 10             	mov    0x10(%eax),%eax
80101153:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101157:	89 54 24 08          	mov    %edx,0x8(%esp)
8010115b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010115e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101162:	89 04 24             	mov    %eax,(%esp)
80101165:	e8 f4 0b 00 00       	call   80101d5e <readi>
8010116a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010116d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101171:	7e 11                	jle    80101184 <fileread+0x9b>
      f->off += r;
80101173:	8b 45 08             	mov    0x8(%ebp),%eax
80101176:	8b 50 14             	mov    0x14(%eax),%edx
80101179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010117c:	01 c2                	add    %eax,%edx
8010117e:	8b 45 08             	mov    0x8(%ebp),%eax
80101181:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101184:	8b 45 08             	mov    0x8(%ebp),%eax
80101187:	8b 40 10             	mov    0x10(%eax),%eax
8010118a:	89 04 24             	mov    %eax,(%esp)
8010118d:	e8 24 08 00 00       	call   801019b6 <iunlock>
    return r;
80101192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101195:	eb 0c                	jmp    801011a3 <fileread+0xba>
  }
  panic("fileread");
80101197:	c7 04 24 32 98 10 80 	movl   $0x80109832,(%esp)
8010119e:	e8 9a f3 ff ff       	call   8010053d <panic>
}
801011a3:	c9                   	leave  
801011a4:	c3                   	ret    

801011a5 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011a5:	55                   	push   %ebp
801011a6:	89 e5                	mov    %esp,%ebp
801011a8:	53                   	push   %ebx
801011a9:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011ac:	8b 45 08             	mov    0x8(%ebp),%eax
801011af:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011b3:	84 c0                	test   %al,%al
801011b5:	75 0a                	jne    801011c1 <filewrite+0x1c>
    return -1;
801011b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011bc:	e9 23 01 00 00       	jmp    801012e4 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801011c1:	8b 45 08             	mov    0x8(%ebp),%eax
801011c4:	8b 00                	mov    (%eax),%eax
801011c6:	83 f8 01             	cmp    $0x1,%eax
801011c9:	75 21                	jne    801011ec <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011cb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ce:	8b 40 0c             	mov    0xc(%eax),%eax
801011d1:	8b 55 10             	mov    0x10(%ebp),%edx
801011d4:	89 54 24 08          	mov    %edx,0x8(%esp)
801011d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801011db:	89 54 24 04          	mov    %edx,0x4(%esp)
801011df:	89 04 24             	mov    %eax,(%esp)
801011e2:	e8 f6 2b 00 00       	call   80103ddd <pipewrite>
801011e7:	e9 f8 00 00 00       	jmp    801012e4 <filewrite+0x13f>
  if(f->type == FD_INODE){
801011ec:	8b 45 08             	mov    0x8(%ebp),%eax
801011ef:	8b 00                	mov    (%eax),%eax
801011f1:	83 f8 02             	cmp    $0x2,%eax
801011f4:	0f 85 de 00 00 00    	jne    801012d8 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801011fa:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101201:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101208:	e9 a8 00 00 00       	jmp    801012b5 <filewrite+0x110>
      int n1 = n - i;
8010120d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101210:	8b 55 10             	mov    0x10(%ebp),%edx
80101213:	89 d1                	mov    %edx,%ecx
80101215:	29 c1                	sub    %eax,%ecx
80101217:	89 c8                	mov    %ecx,%eax
80101219:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010121f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101222:	7e 06                	jle    8010122a <filewrite+0x85>
        n1 = max;
80101224:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101227:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010122a:	e8 ee 1f 00 00       	call   8010321d <begin_trans>
      ilock(f->ip);
8010122f:	8b 45 08             	mov    0x8(%ebp),%eax
80101232:	8b 40 10             	mov    0x10(%eax),%eax
80101235:	89 04 24             	mov    %eax,(%esp)
80101238:	e8 2b 06 00 00       	call   80101868 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010123d:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101240:	8b 45 08             	mov    0x8(%ebp),%eax
80101243:	8b 48 14             	mov    0x14(%eax),%ecx
80101246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101249:	89 c2                	mov    %eax,%edx
8010124b:	03 55 0c             	add    0xc(%ebp),%edx
8010124e:	8b 45 08             	mov    0x8(%ebp),%eax
80101251:	8b 40 10             	mov    0x10(%eax),%eax
80101254:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010125c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101260:	89 04 24             	mov    %eax,(%esp)
80101263:	e8 61 0c 00 00       	call   80101ec9 <writei>
80101268:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010126b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010126f:	7e 11                	jle    80101282 <filewrite+0xdd>
        f->off += r;
80101271:	8b 45 08             	mov    0x8(%ebp),%eax
80101274:	8b 50 14             	mov    0x14(%eax),%edx
80101277:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010127a:	01 c2                	add    %eax,%edx
8010127c:	8b 45 08             	mov    0x8(%ebp),%eax
8010127f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101282:	8b 45 08             	mov    0x8(%ebp),%eax
80101285:	8b 40 10             	mov    0x10(%eax),%eax
80101288:	89 04 24             	mov    %eax,(%esp)
8010128b:	e8 26 07 00 00       	call   801019b6 <iunlock>
      commit_trans();
80101290:	e8 ab 1f 00 00       	call   80103240 <commit_trans>

      if(r < 0)
80101295:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101299:	78 28                	js     801012c3 <filewrite+0x11e>
        break;
      if(r != n1)
8010129b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010129e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012a1:	74 0c                	je     801012af <filewrite+0x10a>
        panic("short filewrite");
801012a3:	c7 04 24 3b 98 10 80 	movl   $0x8010983b,(%esp)
801012aa:	e8 8e f2 ff ff       	call   8010053d <panic>
      i += r;
801012af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012b2:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b8:	3b 45 10             	cmp    0x10(%ebp),%eax
801012bb:	0f 8c 4c ff ff ff    	jl     8010120d <filewrite+0x68>
801012c1:	eb 01                	jmp    801012c4 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
801012c3:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c7:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ca:	75 05                	jne    801012d1 <filewrite+0x12c>
801012cc:	8b 45 10             	mov    0x10(%ebp),%eax
801012cf:	eb 05                	jmp    801012d6 <filewrite+0x131>
801012d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012d6:	eb 0c                	jmp    801012e4 <filewrite+0x13f>
  }
  panic("filewrite");
801012d8:	c7 04 24 4b 98 10 80 	movl   $0x8010984b,(%esp)
801012df:	e8 59 f2 ff ff       	call   8010053d <panic>
}
801012e4:	83 c4 24             	add    $0x24,%esp
801012e7:	5b                   	pop    %ebx
801012e8:	5d                   	pop    %ebp
801012e9:	c3                   	ret    
	...

801012ec <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012f2:	8b 45 08             	mov    0x8(%ebp),%eax
801012f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801012fc:	00 
801012fd:	89 04 24             	mov    %eax,(%esp)
80101300:	e8 a1 ee ff ff       	call   801001a6 <bread>
80101305:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101308:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010130b:	83 c0 18             	add    $0x18,%eax
8010130e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101315:	00 
80101316:	89 44 24 04          	mov    %eax,0x4(%esp)
8010131a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010131d:	89 04 24             	mov    %eax,(%esp)
80101320:	e8 14 50 00 00       	call   80106339 <memmove>
  brelse(bp);
80101325:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101328:	89 04 24             	mov    %eax,(%esp)
8010132b:	e8 e7 ee ff ff       	call   80100217 <brelse>
}
80101330:	c9                   	leave  
80101331:	c3                   	ret    

80101332 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101332:	55                   	push   %ebp
80101333:	89 e5                	mov    %esp,%ebp
80101335:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101338:	8b 55 0c             	mov    0xc(%ebp),%edx
8010133b:	8b 45 08             	mov    0x8(%ebp),%eax
8010133e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101342:	89 04 24             	mov    %eax,(%esp)
80101345:	e8 5c ee ff ff       	call   801001a6 <bread>
8010134a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101350:	83 c0 18             	add    $0x18,%eax
80101353:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010135a:	00 
8010135b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101362:	00 
80101363:	89 04 24             	mov    %eax,(%esp)
80101366:	e8 fb 4e 00 00       	call   80106266 <memset>
  log_write(bp);
8010136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136e:	89 04 24             	mov    %eax,(%esp)
80101371:	e8 16 1f 00 00       	call   8010328c <log_write>
  brelse(bp);
80101376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101379:	89 04 24             	mov    %eax,(%esp)
8010137c:	e8 96 ee ff ff       	call   80100217 <brelse>
}
80101381:	c9                   	leave  
80101382:	c3                   	ret    

80101383 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101383:	55                   	push   %ebp
80101384:	89 e5                	mov    %esp,%ebp
80101386:	53                   	push   %ebx
80101387:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010138a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101391:	8b 45 08             	mov    0x8(%ebp),%eax
80101394:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101397:	89 54 24 04          	mov    %edx,0x4(%esp)
8010139b:	89 04 24             	mov    %eax,(%esp)
8010139e:	e8 49 ff ff ff       	call   801012ec <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013aa:	e9 11 01 00 00       	jmp    801014c0 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013b8:	85 c0                	test   %eax,%eax
801013ba:	0f 48 c2             	cmovs  %edx,%eax
801013bd:	c1 f8 0c             	sar    $0xc,%eax
801013c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013c3:	c1 ea 03             	shr    $0x3,%edx
801013c6:	01 d0                	add    %edx,%eax
801013c8:	83 c0 03             	add    $0x3,%eax
801013cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	89 04 24             	mov    %eax,(%esp)
801013d5:	e8 cc ed ff ff       	call   801001a6 <bread>
801013da:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013e4:	e9 a7 00 00 00       	jmp    80101490 <balloc+0x10d>
      m = 1 << (bi % 8);
801013e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013ec:	89 c2                	mov    %eax,%edx
801013ee:	c1 fa 1f             	sar    $0x1f,%edx
801013f1:	c1 ea 1d             	shr    $0x1d,%edx
801013f4:	01 d0                	add    %edx,%eax
801013f6:	83 e0 07             	and    $0x7,%eax
801013f9:	29 d0                	sub    %edx,%eax
801013fb:	ba 01 00 00 00       	mov    $0x1,%edx
80101400:	89 d3                	mov    %edx,%ebx
80101402:	89 c1                	mov    %eax,%ecx
80101404:	d3 e3                	shl    %cl,%ebx
80101406:	89 d8                	mov    %ebx,%eax
80101408:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010140b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010140e:	8d 50 07             	lea    0x7(%eax),%edx
80101411:	85 c0                	test   %eax,%eax
80101413:	0f 48 c2             	cmovs  %edx,%eax
80101416:	c1 f8 03             	sar    $0x3,%eax
80101419:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010141c:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101421:	0f b6 c0             	movzbl %al,%eax
80101424:	23 45 e8             	and    -0x18(%ebp),%eax
80101427:	85 c0                	test   %eax,%eax
80101429:	75 61                	jne    8010148c <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
8010142b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142e:	8d 50 07             	lea    0x7(%eax),%edx
80101431:	85 c0                	test   %eax,%eax
80101433:	0f 48 c2             	cmovs  %edx,%eax
80101436:	c1 f8 03             	sar    $0x3,%eax
80101439:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010143c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101441:	89 d1                	mov    %edx,%ecx
80101443:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101446:	09 ca                	or     %ecx,%edx
80101448:	89 d1                	mov    %edx,%ecx
8010144a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010144d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101451:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101454:	89 04 24             	mov    %eax,(%esp)
80101457:	e8 30 1e 00 00       	call   8010328c <log_write>
        brelse(bp);
8010145c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010145f:	89 04 24             	mov    %eax,(%esp)
80101462:	e8 b0 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010146d:	01 c2                	add    %eax,%edx
8010146f:	8b 45 08             	mov    0x8(%ebp),%eax
80101472:	89 54 24 04          	mov    %edx,0x4(%esp)
80101476:	89 04 24             	mov    %eax,(%esp)
80101479:	e8 b4 fe ff ff       	call   80101332 <bzero>
        return b + bi;
8010147e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101481:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101484:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101486:	83 c4 34             	add    $0x34,%esp
80101489:	5b                   	pop    %ebx
8010148a:	5d                   	pop    %ebp
8010148b:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010148c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101490:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101497:	7f 15                	jg     801014ae <balloc+0x12b>
80101499:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010149f:	01 d0                	add    %edx,%eax
801014a1:	89 c2                	mov    %eax,%edx
801014a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014a6:	39 c2                	cmp    %eax,%edx
801014a8:	0f 82 3b ff ff ff    	jb     801013e9 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014b1:	89 04 24             	mov    %eax,(%esp)
801014b4:	e8 5e ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014b9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014c6:	39 c2                	cmp    %eax,%edx
801014c8:	0f 82 e1 fe ff ff    	jb     801013af <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014ce:	c7 04 24 55 98 10 80 	movl   $0x80109855,(%esp)
801014d5:	e8 63 f0 ff ff       	call   8010053d <panic>

801014da <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014da:	55                   	push   %ebp
801014db:	89 e5                	mov    %esp,%ebp
801014dd:	53                   	push   %ebx
801014de:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014e1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801014e8:	8b 45 08             	mov    0x8(%ebp),%eax
801014eb:	89 04 24             	mov    %eax,(%esp)
801014ee:	e8 f9 fd ff ff       	call   801012ec <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f6:	89 c2                	mov    %eax,%edx
801014f8:	c1 ea 0c             	shr    $0xc,%edx
801014fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014fe:	c1 e8 03             	shr    $0x3,%eax
80101501:	01 d0                	add    %edx,%eax
80101503:	8d 50 03             	lea    0x3(%eax),%edx
80101506:	8b 45 08             	mov    0x8(%ebp),%eax
80101509:	89 54 24 04          	mov    %edx,0x4(%esp)
8010150d:	89 04 24             	mov    %eax,(%esp)
80101510:	e8 91 ec ff ff       	call   801001a6 <bread>
80101515:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101518:	8b 45 0c             	mov    0xc(%ebp),%eax
8010151b:	25 ff 0f 00 00       	and    $0xfff,%eax
80101520:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101523:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101526:	89 c2                	mov    %eax,%edx
80101528:	c1 fa 1f             	sar    $0x1f,%edx
8010152b:	c1 ea 1d             	shr    $0x1d,%edx
8010152e:	01 d0                	add    %edx,%eax
80101530:	83 e0 07             	and    $0x7,%eax
80101533:	29 d0                	sub    %edx,%eax
80101535:	ba 01 00 00 00       	mov    $0x1,%edx
8010153a:	89 d3                	mov    %edx,%ebx
8010153c:	89 c1                	mov    %eax,%ecx
8010153e:	d3 e3                	shl    %cl,%ebx
80101540:	89 d8                	mov    %ebx,%eax
80101542:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101548:	8d 50 07             	lea    0x7(%eax),%edx
8010154b:	85 c0                	test   %eax,%eax
8010154d:	0f 48 c2             	cmovs  %edx,%eax
80101550:	c1 f8 03             	sar    $0x3,%eax
80101553:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101556:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010155b:	0f b6 c0             	movzbl %al,%eax
8010155e:	23 45 ec             	and    -0x14(%ebp),%eax
80101561:	85 c0                	test   %eax,%eax
80101563:	75 0c                	jne    80101571 <bfree+0x97>
    panic("freeing free block");
80101565:	c7 04 24 6b 98 10 80 	movl   $0x8010986b,(%esp)
8010156c:	e8 cc ef ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101571:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101574:	8d 50 07             	lea    0x7(%eax),%edx
80101577:	85 c0                	test   %eax,%eax
80101579:	0f 48 c2             	cmovs  %edx,%eax
8010157c:	c1 f8 03             	sar    $0x3,%eax
8010157f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101582:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101587:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010158a:	f7 d1                	not    %ecx
8010158c:	21 ca                	and    %ecx,%edx
8010158e:	89 d1                	mov    %edx,%ecx
80101590:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101593:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010159a:	89 04 24             	mov    %eax,(%esp)
8010159d:	e8 ea 1c 00 00       	call   8010328c <log_write>
  brelse(bp);
801015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a5:	89 04 24             	mov    %eax,(%esp)
801015a8:	e8 6a ec ff ff       	call   80100217 <brelse>
}
801015ad:	83 c4 34             	add    $0x34,%esp
801015b0:	5b                   	pop    %ebx
801015b1:	5d                   	pop    %ebp
801015b2:	c3                   	ret    

801015b3 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015b3:	55                   	push   %ebp
801015b4:	89 e5                	mov    %esp,%ebp
801015b6:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015b9:	c7 44 24 04 7e 98 10 	movl   $0x8010987e,0x4(%esp)
801015c0:	80 
801015c1:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
801015c8:	e8 15 4a 00 00       	call   80105fe2 <initlock>
}
801015cd:	c9                   	leave  
801015ce:	c3                   	ret    

801015cf <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015cf:	55                   	push   %ebp
801015d0:	89 e5                	mov    %esp,%ebp
801015d2:	83 ec 48             	sub    $0x48,%esp
801015d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801015d8:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015dc:	8b 45 08             	mov    0x8(%ebp),%eax
801015df:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015e2:	89 54 24 04          	mov    %edx,0x4(%esp)
801015e6:	89 04 24             	mov    %eax,(%esp)
801015e9:	e8 fe fc ff ff       	call   801012ec <readsb>
  for(inum = 1; inum < sb.ninodes; inum++){
801015ee:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015f5:	e9 98 00 00 00       	jmp    80101692 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fd:	c1 e8 03             	shr    $0x3,%eax
80101600:	83 c0 02             	add    $0x2,%eax
80101603:	89 44 24 04          	mov    %eax,0x4(%esp)
80101607:	8b 45 08             	mov    0x8(%ebp),%eax
8010160a:	89 04 24             	mov    %eax,(%esp)
8010160d:	e8 94 eb ff ff       	call   801001a6 <bread>
80101612:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101615:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101618:	8d 50 18             	lea    0x18(%eax),%edx
8010161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161e:	83 e0 07             	and    $0x7,%eax
80101621:	c1 e0 06             	shl    $0x6,%eax
80101624:	01 d0                	add    %edx,%eax
80101626:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101629:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010162c:	0f b7 00             	movzwl (%eax),%eax
8010162f:	66 85 c0             	test   %ax,%ax
80101632:	75 4f                	jne    80101683 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101634:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010163b:	00 
8010163c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101643:	00 
80101644:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101647:	89 04 24             	mov    %eax,(%esp)
8010164a:	e8 17 4c 00 00       	call   80106266 <memset>
      dip->type = type;
8010164f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101652:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101656:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165c:	89 04 24             	mov    %eax,(%esp)
8010165f:	e8 28 1c 00 00       	call   8010328c <log_write>
      brelse(bp);
80101664:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101667:	89 04 24             	mov    %eax,(%esp)
8010166a:	e8 a8 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010166f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101672:	89 44 24 04          	mov    %eax,0x4(%esp)
80101676:	8b 45 08             	mov    0x8(%ebp),%eax
80101679:	89 04 24             	mov    %eax,(%esp)
8010167c:	e8 e3 00 00 00       	call   80101764 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101681:	c9                   	leave  
80101682:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
80101683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101686:	89 04 24             	mov    %eax,(%esp)
80101689:	e8 89 eb ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
  for(inum = 1; inum < sb.ninodes; inum++){
8010168e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101692:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101695:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101698:	39 c2                	cmp    %eax,%edx
8010169a:	0f 82 5a ff ff ff    	jb     801015fa <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016a0:	c7 04 24 85 98 10 80 	movl   $0x80109885,(%esp)
801016a7:	e8 91 ee ff ff       	call   8010053d <panic>

801016ac <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016ac:	55                   	push   %ebp
801016ad:	89 e5                	mov    %esp,%ebp
801016af:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016b2:	8b 45 08             	mov    0x8(%ebp),%eax
801016b5:	8b 40 04             	mov    0x4(%eax),%eax
801016b8:	c1 e8 03             	shr    $0x3,%eax
801016bb:	8d 50 02             	lea    0x2(%eax),%edx
801016be:	8b 45 08             	mov    0x8(%ebp),%eax
801016c1:	8b 00                	mov    (%eax),%eax
801016c3:	89 54 24 04          	mov    %edx,0x4(%esp)
801016c7:	89 04 24             	mov    %eax,(%esp)
801016ca:	e8 d7 ea ff ff       	call   801001a6 <bread>
801016cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d5:	8d 50 18             	lea    0x18(%eax),%edx
801016d8:	8b 45 08             	mov    0x8(%ebp),%eax
801016db:	8b 40 04             	mov    0x4(%eax),%eax
801016de:	83 e0 07             	and    $0x7,%eax
801016e1:	c1 e0 06             	shl    $0x6,%eax
801016e4:	01 d0                	add    %edx,%eax
801016e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016e9:	8b 45 08             	mov    0x8(%ebp),%eax
801016ec:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f3:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016f6:	8b 45 08             	mov    0x8(%ebp),%eax
801016f9:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101700:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101704:	8b 45 08             	mov    0x8(%ebp),%eax
80101707:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101712:	8b 45 08             	mov    0x8(%ebp),%eax
80101715:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101720:	8b 45 08             	mov    0x8(%ebp),%eax
80101723:	8b 50 18             	mov    0x18(%eax),%edx
80101726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101729:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010172c:	8b 45 08             	mov    0x8(%ebp),%eax
8010172f:	8d 50 1c             	lea    0x1c(%eax),%edx
80101732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101735:	83 c0 0c             	add    $0xc,%eax
80101738:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010173f:	00 
80101740:	89 54 24 04          	mov    %edx,0x4(%esp)
80101744:	89 04 24             	mov    %eax,(%esp)
80101747:	e8 ed 4b 00 00       	call   80106339 <memmove>
  log_write(bp);
8010174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174f:	89 04 24             	mov    %eax,(%esp)
80101752:	e8 35 1b 00 00       	call   8010328c <log_write>
  brelse(bp);
80101757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175a:	89 04 24             	mov    %eax,(%esp)
8010175d:	e8 b5 ea ff ff       	call   80100217 <brelse>
}
80101762:	c9                   	leave  
80101763:	c3                   	ret    

80101764 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101764:	55                   	push   %ebp
80101765:	89 e5                	mov    %esp,%ebp
80101767:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010176a:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
80101771:	e8 8d 48 00 00       	call   80106003 <acquire>

  // Is the inode already cached?
  empty = 0;
80101776:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010177d:	c7 45 f4 f4 08 11 80 	movl   $0x801108f4,-0xc(%ebp)
80101784:	eb 59                	jmp    801017df <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101789:	8b 40 08             	mov    0x8(%eax),%eax
8010178c:	85 c0                	test   %eax,%eax
8010178e:	7e 35                	jle    801017c5 <iget+0x61>
80101790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101793:	8b 00                	mov    (%eax),%eax
80101795:	3b 45 08             	cmp    0x8(%ebp),%eax
80101798:	75 2b                	jne    801017c5 <iget+0x61>
8010179a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179d:	8b 40 04             	mov    0x4(%eax),%eax
801017a0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017a3:	75 20                	jne    801017c5 <iget+0x61>
      ip->ref++;
801017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a8:	8b 40 08             	mov    0x8(%eax),%eax
801017ab:	8d 50 01             	lea    0x1(%eax),%edx
801017ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b1:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017b4:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
801017bb:	e8 bb 48 00 00       	call   8010607b <release>
      return ip;
801017c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c3:	eb 6f                	jmp    80101834 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017c9:	75 10                	jne    801017db <iget+0x77>
801017cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ce:	8b 40 08             	mov    0x8(%eax),%eax
801017d1:	85 c0                	test   %eax,%eax
801017d3:	75 06                	jne    801017db <iget+0x77>
      empty = ip;
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017db:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017df:	81 7d f4 94 18 11 80 	cmpl   $0x80111894,-0xc(%ebp)
801017e6:	72 9e                	jb     80101786 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017ec:	75 0c                	jne    801017fa <iget+0x96>
    panic("iget: no inodes");
801017ee:	c7 04 24 97 98 10 80 	movl   $0x80109897,(%esp)
801017f5:	e8 43 ed ff ff       	call   8010053d <panic>

  ip = empty;
801017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101803:	8b 55 08             	mov    0x8(%ebp),%edx
80101806:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010180e:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101814:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010181b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101825:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
8010182c:	e8 4a 48 00 00       	call   8010607b <release>

  return ip;
80101831:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101834:	c9                   	leave  
80101835:	c3                   	ret    

80101836 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101836:	55                   	push   %ebp
80101837:	89 e5                	mov    %esp,%ebp
80101839:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010183c:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
80101843:	e8 bb 47 00 00       	call   80106003 <acquire>
  ip->ref++;
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 08             	mov    0x8(%eax),%eax
8010184e:	8d 50 01             	lea    0x1(%eax),%edx
80101851:	8b 45 08             	mov    0x8(%ebp),%eax
80101854:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101857:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
8010185e:	e8 18 48 00 00       	call   8010607b <release>
  return ip;
80101863:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101866:	c9                   	leave  
80101867:	c3                   	ret    

80101868 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101868:	55                   	push   %ebp
80101869:	89 e5                	mov    %esp,%ebp
8010186b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010186e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101872:	74 0a                	je     8010187e <ilock+0x16>
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	8b 40 08             	mov    0x8(%eax),%eax
8010187a:	85 c0                	test   %eax,%eax
8010187c:	7f 0c                	jg     8010188a <ilock+0x22>
    panic("ilock");
8010187e:	c7 04 24 a7 98 10 80 	movl   $0x801098a7,(%esp)
80101885:	e8 b3 ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
8010188a:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
80101891:	e8 6d 47 00 00       	call   80106003 <acquire>
  while(ip->flags & I_BUSY)//{}
80101896:	eb 13                	jmp    801018ab <ilock+0x43>
    sleep(ip, &icache.lock);
80101898:	c7 44 24 04 c0 08 11 	movl   $0x801108c0,0x4(%esp)
8010189f:	80 
801018a0:	8b 45 08             	mov    0x8(%ebp),%eax
801018a3:	89 04 24             	mov    %eax,(%esp)
801018a6:	e8 ae 30 00 00       	call   80104959 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)//{}
801018ab:	8b 45 08             	mov    0x8(%ebp),%eax
801018ae:	8b 40 0c             	mov    0xc(%eax),%eax
801018b1:	83 e0 01             	and    $0x1,%eax
801018b4:	84 c0                	test   %al,%al
801018b6:	75 e0                	jne    80101898 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018b8:	8b 45 08             	mov    0x8(%ebp),%eax
801018bb:	8b 40 0c             	mov    0xc(%eax),%eax
801018be:	89 c2                	mov    %eax,%edx
801018c0:	83 ca 01             	or     $0x1,%edx
801018c3:	8b 45 08             	mov    0x8(%ebp),%eax
801018c6:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018c9:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
801018d0:	e8 a6 47 00 00       	call   8010607b <release>

  if(!(ip->flags & I_VALID)){
801018d5:	8b 45 08             	mov    0x8(%ebp),%eax
801018d8:	8b 40 0c             	mov    0xc(%eax),%eax
801018db:	83 e0 02             	and    $0x2,%eax
801018de:	85 c0                	test   %eax,%eax
801018e0:	0f 85 ce 00 00 00    	jne    801019b4 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018e6:	8b 45 08             	mov    0x8(%ebp),%eax
801018e9:	8b 40 04             	mov    0x4(%eax),%eax
801018ec:	c1 e8 03             	shr    $0x3,%eax
801018ef:	8d 50 02             	lea    0x2(%eax),%edx
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
801018f5:	8b 00                	mov    (%eax),%eax
801018f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801018fb:	89 04 24             	mov    %eax,(%esp)
801018fe:	e8 a3 e8 ff ff       	call   801001a6 <bread>
80101903:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8d 50 18             	lea    0x18(%eax),%edx
8010190c:	8b 45 08             	mov    0x8(%ebp),%eax
8010190f:	8b 40 04             	mov    0x4(%eax),%eax
80101912:	83 e0 07             	and    $0x7,%eax
80101915:	c1 e0 06             	shl    $0x6,%eax
80101918:	01 d0                	add    %edx,%eax
8010191a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
8010191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101920:	0f b7 10             	movzwl (%eax),%edx
80101923:	8b 45 08             	mov    0x8(%ebp),%eax
80101926:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010192a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101931:	8b 45 08             	mov    0x8(%ebp),%eax
80101934:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010193f:	8b 45 08             	mov    0x8(%ebp),%eax
80101942:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101946:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101949:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010194d:	8b 45 08             	mov    0x8(%ebp),%eax
80101950:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101957:	8b 50 08             	mov    0x8(%eax),%edx
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101963:	8d 50 0c             	lea    0xc(%eax),%edx
80101966:	8b 45 08             	mov    0x8(%ebp),%eax
80101969:	83 c0 1c             	add    $0x1c,%eax
8010196c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101973:	00 
80101974:	89 54 24 04          	mov    %edx,0x4(%esp)
80101978:	89 04 24             	mov    %eax,(%esp)
8010197b:	e8 b9 49 00 00       	call   80106339 <memmove>
    brelse(bp);
80101980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101983:	89 04 24             	mov    %eax,(%esp)
80101986:	e8 8c e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010198b:	8b 45 08             	mov    0x8(%ebp),%eax
8010198e:	8b 40 0c             	mov    0xc(%eax),%eax
80101991:	89 c2                	mov    %eax,%edx
80101993:	83 ca 02             	or     $0x2,%edx
80101996:	8b 45 08             	mov    0x8(%ebp),%eax
80101999:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010199c:	8b 45 08             	mov    0x8(%ebp),%eax
8010199f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019a3:	66 85 c0             	test   %ax,%ax
801019a6:	75 0c                	jne    801019b4 <ilock+0x14c>
      panic("ilock: no type");
801019a8:	c7 04 24 ad 98 10 80 	movl   $0x801098ad,(%esp)
801019af:	e8 89 eb ff ff       	call   8010053d <panic>
  }
}
801019b4:	c9                   	leave  
801019b5:	c3                   	ret    

801019b6 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019b6:	55                   	push   %ebp
801019b7:	89 e5                	mov    %esp,%ebp
801019b9:	83 ec 18             	sub    $0x18,%esp
  //cprintf("ip = %x\n",ip);
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019bc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019c0:	74 17                	je     801019d9 <iunlock+0x23>
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	8b 40 0c             	mov    0xc(%eax),%eax
801019c8:	83 e0 01             	and    $0x1,%eax
801019cb:	85 c0                	test   %eax,%eax
801019cd:	74 0a                	je     801019d9 <iunlock+0x23>
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	8b 40 08             	mov    0x8(%eax),%eax
801019d5:	85 c0                	test   %eax,%eax
801019d7:	7f 0c                	jg     801019e5 <iunlock+0x2f>
    panic("iunlock");
801019d9:	c7 04 24 bc 98 10 80 	movl   $0x801098bc,(%esp)
801019e0:	e8 58 eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801019e5:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
801019ec:	e8 12 46 00 00       	call   80106003 <acquire>
  ip->flags &= ~I_BUSY;
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	8b 40 0c             	mov    0xc(%eax),%eax
801019f7:	89 c2                	mov    %eax,%edx
801019f9:	83 e2 fe             	and    $0xfffffffe,%edx
801019fc:	8b 45 08             	mov    0x8(%ebp),%eax
801019ff:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a02:	8b 45 08             	mov    0x8(%ebp),%eax
80101a05:	89 04 24             	mov    %eax,(%esp)
80101a08:	e8 8b 30 00 00       	call   80104a98 <wakeup>
  release(&icache.lock);
80101a0d:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
80101a14:	e8 62 46 00 00       	call   8010607b <release>
}
80101a19:	c9                   	leave  
80101a1a:	c3                   	ret    

80101a1b <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
80101a1b:	55                   	push   %ebp
80101a1c:	89 e5                	mov    %esp,%ebp
80101a1e:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a21:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
80101a28:	e8 d6 45 00 00       	call   80106003 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a30:	8b 40 08             	mov    0x8(%eax),%eax
80101a33:	83 f8 01             	cmp    $0x1,%eax
80101a36:	0f 85 93 00 00 00    	jne    80101acf <iput+0xb4>
80101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3f:	8b 40 0c             	mov    0xc(%eax),%eax
80101a42:	83 e0 02             	and    $0x2,%eax
80101a45:	85 c0                	test   %eax,%eax
80101a47:	0f 84 82 00 00 00    	je     80101acf <iput+0xb4>
80101a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a50:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a54:	66 85 c0             	test   %ax,%ax
80101a57:	75 76                	jne    80101acf <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	8b 40 0c             	mov    0xc(%eax),%eax
80101a5f:	83 e0 01             	and    $0x1,%eax
80101a62:	84 c0                	test   %al,%al
80101a64:	74 0c                	je     80101a72 <iput+0x57>
      panic("iput busy");
80101a66:	c7 04 24 c4 98 10 80 	movl   $0x801098c4,(%esp)
80101a6d:	e8 cb ea ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101a72:	8b 45 08             	mov    0x8(%ebp),%eax
80101a75:	8b 40 0c             	mov    0xc(%eax),%eax
80101a78:	89 c2                	mov    %eax,%edx
80101a7a:	83 ca 01             	or     $0x1,%edx
80101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a80:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a83:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
80101a8a:	e8 ec 45 00 00       	call   8010607b <release>
    itrunc(ip);
80101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a92:	89 04 24             	mov    %eax,(%esp)
80101a95:	e8 72 01 00 00       	call   80101c0c <itrunc>
    ip->type = 0;
80101a9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9d:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	89 04 24             	mov    %eax,(%esp)
80101aa9:	e8 fe fb ff ff       	call   801016ac <iupdate>
    acquire(&icache.lock);
80101aae:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
80101ab5:	e8 49 45 00 00       	call   80106003 <acquire>
    ip->flags = 0;
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac7:	89 04 24             	mov    %eax,(%esp)
80101aca:	e8 c9 2f 00 00       	call   80104a98 <wakeup>
  }
  ip->ref--;
80101acf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad2:	8b 40 08             	mov    0x8(%eax),%eax
80101ad5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ad8:	8b 45 08             	mov    0x8(%ebp),%eax
80101adb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ade:	c7 04 24 c0 08 11 80 	movl   $0x801108c0,(%esp)
80101ae5:	e8 91 45 00 00       	call   8010607b <release>
}
80101aea:	c9                   	leave  
80101aeb:	c3                   	ret    

80101aec <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101aec:	55                   	push   %ebp
80101aed:	89 e5                	mov    %esp,%ebp
80101aef:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101af2:	8b 45 08             	mov    0x8(%ebp),%eax
80101af5:	89 04 24             	mov    %eax,(%esp)
80101af8:	e8 b9 fe ff ff       	call   801019b6 <iunlock>
  iput(ip);
80101afd:	8b 45 08             	mov    0x8(%ebp),%eax
80101b00:	89 04 24             	mov    %eax,(%esp)
80101b03:	e8 13 ff ff ff       	call   80101a1b <iput>
}
80101b08:	c9                   	leave  
80101b09:	c3                   	ret    

80101b0a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b0a:	55                   	push   %ebp
80101b0b:	89 e5                	mov    %esp,%ebp
80101b0d:	53                   	push   %ebx
80101b0e:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b11:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b15:	77 3e                	ja     80101b55 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b1d:	83 c2 04             	add    $0x4,%edx
80101b20:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b2b:	75 20                	jne    80101b4d <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b30:	8b 00                	mov    (%eax),%eax
80101b32:	89 04 24             	mov    %eax,(%esp)
80101b35:	e8 49 f8 ff ff       	call   80101383 <balloc>
80101b3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b40:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b43:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b49:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b50:	e9 b1 00 00 00       	jmp    80101c06 <bmap+0xfc>
  }
  bn -= NDIRECT;
80101b55:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b59:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b5d:	0f 87 97 00 00 00    	ja     80101bfa <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b63:	8b 45 08             	mov    0x8(%ebp),%eax
80101b66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b70:	75 19                	jne    80101b8b <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b72:	8b 45 08             	mov    0x8(%ebp),%eax
80101b75:	8b 00                	mov    (%eax),%eax
80101b77:	89 04 24             	mov    %eax,(%esp)
80101b7a:	e8 04 f8 ff ff       	call   80101383 <balloc>
80101b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b82:	8b 45 08             	mov    0x8(%ebp),%eax
80101b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b88:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8e:	8b 00                	mov    (%eax),%eax
80101b90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b93:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b97:	89 04 24             	mov    %eax,(%esp)
80101b9a:	e8 07 e6 ff ff       	call   801001a6 <bread>
80101b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba5:	83 c0 18             	add    $0x18,%eax
80101ba8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bab:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bae:	c1 e0 02             	shl    $0x2,%eax
80101bb1:	03 45 ec             	add    -0x14(%ebp),%eax
80101bb4:	8b 00                	mov    (%eax),%eax
80101bb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bb9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bbd:	75 2b                	jne    80101bea <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bc2:	c1 e0 02             	shl    $0x2,%eax
80101bc5:	89 c3                	mov    %eax,%ebx
80101bc7:	03 5d ec             	add    -0x14(%ebp),%ebx
80101bca:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcd:	8b 00                	mov    (%eax),%eax
80101bcf:	89 04 24             	mov    %eax,(%esp)
80101bd2:	e8 ac f7 ff ff       	call   80101383 <balloc>
80101bd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bdd:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be2:	89 04 24             	mov    %eax,(%esp)
80101be5:	e8 a2 16 00 00       	call   8010328c <log_write>
    }
    brelse(bp);
80101bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bed:	89 04 24             	mov    %eax,(%esp)
80101bf0:	e8 22 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf8:	eb 0c                	jmp    80101c06 <bmap+0xfc>
  }

  panic("bmap: out of range");
80101bfa:	c7 04 24 ce 98 10 80 	movl   $0x801098ce,(%esp)
80101c01:	e8 37 e9 ff ff       	call   8010053d <panic>
}
80101c06:	83 c4 24             	add    $0x24,%esp
80101c09:	5b                   	pop    %ebx
80101c0a:	5d                   	pop    %ebp
80101c0b:	c3                   	ret    

80101c0c <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c0c:	55                   	push   %ebp
80101c0d:	89 e5                	mov    %esp,%ebp
80101c0f:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c19:	eb 44                	jmp    80101c5f <itrunc+0x53>
    if(ip->addrs[i]){
80101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c21:	83 c2 04             	add    $0x4,%edx
80101c24:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c28:	85 c0                	test   %eax,%eax
80101c2a:	74 2f                	je     80101c5b <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c32:	83 c2 04             	add    $0x4,%edx
80101c35:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c39:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3c:	8b 00                	mov    (%eax),%eax
80101c3e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c42:	89 04 24             	mov    %eax,(%esp)
80101c45:	e8 90 f8 ff ff       	call   801014da <bfree>
      ip->addrs[i] = 0;
80101c4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c50:	83 c2 04             	add    $0x4,%edx
80101c53:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c5a:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c5b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c5f:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c63:	7e b6                	jle    80101c1b <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c65:	8b 45 08             	mov    0x8(%ebp),%eax
80101c68:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c6b:	85 c0                	test   %eax,%eax
80101c6d:	0f 84 8f 00 00 00    	je     80101d02 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c73:	8b 45 08             	mov    0x8(%ebp),%eax
80101c76:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c79:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7c:	8b 00                	mov    (%eax),%eax
80101c7e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c82:	89 04 24             	mov    %eax,(%esp)
80101c85:	e8 1c e5 ff ff       	call   801001a6 <bread>
80101c8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c90:	83 c0 18             	add    $0x18,%eax
80101c93:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c96:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c9d:	eb 2f                	jmp    80101cce <itrunc+0xc2>
      if(a[j])
80101c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ca2:	c1 e0 02             	shl    $0x2,%eax
80101ca5:	03 45 e8             	add    -0x18(%ebp),%eax
80101ca8:	8b 00                	mov    (%eax),%eax
80101caa:	85 c0                	test   %eax,%eax
80101cac:	74 1c                	je     80101cca <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101cae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cb1:	c1 e0 02             	shl    $0x2,%eax
80101cb4:	03 45 e8             	add    -0x18(%ebp),%eax
80101cb7:	8b 10                	mov    (%eax),%edx
80101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbc:	8b 00                	mov    (%eax),%eax
80101cbe:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cc2:	89 04 24             	mov    %eax,(%esp)
80101cc5:	e8 10 f8 ff ff       	call   801014da <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cca:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd1:	83 f8 7f             	cmp    $0x7f,%eax
80101cd4:	76 c9                	jbe    80101c9f <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101cd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cd9:	89 04 24             	mov    %eax,(%esp)
80101cdc:	e8 36 e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce4:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ce7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cea:	8b 00                	mov    (%eax),%eax
80101cec:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cf0:	89 04 24             	mov    %eax,(%esp)
80101cf3:	e8 e2 f7 ff ff       	call   801014da <bfree>
    ip->addrs[NDIRECT] = 0;
80101cf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cfb:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0f:	89 04 24             	mov    %eax,(%esp)
80101d12:	e8 95 f9 ff ff       	call   801016ac <iupdate>
}
80101d17:	c9                   	leave  
80101d18:	c3                   	ret    

80101d19 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d19:	55                   	push   %ebp
80101d1a:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	8b 00                	mov    (%eax),%eax
80101d21:	89 c2                	mov    %eax,%edx
80101d23:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d26:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d29:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2c:	8b 50 04             	mov    0x4(%eax),%edx
80101d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d32:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d3f:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4c:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d50:	8b 45 08             	mov    0x8(%ebp),%eax
80101d53:	8b 50 18             	mov    0x18(%eax),%edx
80101d56:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d59:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d5c:	5d                   	pop    %ebp
80101d5d:	c3                   	ret    

80101d5e <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d5e:	55                   	push   %ebp
80101d5f:	89 e5                	mov    %esp,%ebp
80101d61:	53                   	push   %ebx
80101d62:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d65:	8b 45 08             	mov    0x8(%ebp),%eax
80101d68:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d6c:	66 83 f8 03          	cmp    $0x3,%ax
80101d70:	75 60                	jne    80101dd2 <readi+0x74>
     //cprintf("readi-inside if- ipMajor: %d, ipMinor: %d\n",ip->major,ip->minor);
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d72:	8b 45 08             	mov    0x8(%ebp),%eax
80101d75:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d79:	66 85 c0             	test   %ax,%ax
80101d7c:	78 20                	js     80101d9e <readi+0x40>
80101d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d81:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d85:	66 83 f8 09          	cmp    $0x9,%ax
80101d89:	7f 13                	jg     80101d9e <readi+0x40>
80101d8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d92:	98                   	cwtl   
80101d93:	8b 04 c5 60 08 11 80 	mov    -0x7feef7a0(,%eax,8),%eax
80101d9a:	85 c0                	test   %eax,%eax
80101d9c:	75 0a                	jne    80101da8 <readi+0x4a>
      return -1;
80101d9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101da3:	e9 1b 01 00 00       	jmp    80101ec3 <readi+0x165>
//     cprintf("readi return devsw.read\n");
    return devsw[ip->major].read(ip, dst, n);
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101daf:	98                   	cwtl   
80101db0:	8b 14 c5 60 08 11 80 	mov    -0x7feef7a0(,%eax,8),%edx
80101db7:	8b 45 14             	mov    0x14(%ebp),%eax
80101dba:	89 44 24 08          	mov    %eax,0x8(%esp)
80101dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc8:	89 04 24             	mov    %eax,(%esp)
80101dcb:	ff d2                	call   *%edx
80101dcd:	e9 f1 00 00 00       	jmp    80101ec3 <readi+0x165>
  }
  if(off > ip->size || off + n < off)
80101dd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd5:	8b 40 18             	mov    0x18(%eax),%eax
80101dd8:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ddb:	72 0d                	jb     80101dea <readi+0x8c>
80101ddd:	8b 45 14             	mov    0x14(%ebp),%eax
80101de0:	8b 55 10             	mov    0x10(%ebp),%edx
80101de3:	01 d0                	add    %edx,%eax
80101de5:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de8:	73 0a                	jae    80101df4 <readi+0x96>
    return -1;
80101dea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101def:	e9 cf 00 00 00       	jmp    80101ec3 <readi+0x165>

  if(off + n > ip->size)
80101df4:	8b 45 14             	mov    0x14(%ebp),%eax
80101df7:	8b 55 10             	mov    0x10(%ebp),%edx
80101dfa:	01 c2                	add    %eax,%edx
80101dfc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dff:	8b 40 18             	mov    0x18(%eax),%eax
80101e02:	39 c2                	cmp    %eax,%edx
80101e04:	76 0c                	jbe    80101e12 <readi+0xb4>
    n = ip->size - off;
80101e06:	8b 45 08             	mov    0x8(%ebp),%eax
80101e09:	8b 40 18             	mov    0x18(%eax),%eax
80101e0c:	2b 45 10             	sub    0x10(%ebp),%eax
80101e0f:	89 45 14             	mov    %eax,0x14(%ebp)
 

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e19:	e9 96 00 00 00       	jmp    80101eb4 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e1e:	8b 45 10             	mov    0x10(%ebp),%eax
80101e21:	c1 e8 09             	shr    $0x9,%eax
80101e24:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e28:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2b:	89 04 24             	mov    %eax,(%esp)
80101e2e:	e8 d7 fc ff ff       	call   80101b0a <bmap>
80101e33:	8b 55 08             	mov    0x8(%ebp),%edx
80101e36:	8b 12                	mov    (%edx),%edx
80101e38:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e3c:	89 14 24             	mov    %edx,(%esp)
80101e3f:	e8 62 e3 ff ff       	call   801001a6 <bread>
80101e44:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e47:	8b 45 10             	mov    0x10(%ebp),%eax
80101e4a:	89 c2                	mov    %eax,%edx
80101e4c:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e52:	b8 00 02 00 00       	mov    $0x200,%eax
80101e57:	89 c1                	mov    %eax,%ecx
80101e59:	29 d1                	sub    %edx,%ecx
80101e5b:	89 ca                	mov    %ecx,%edx
80101e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e60:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e63:	89 cb                	mov    %ecx,%ebx
80101e65:	29 c3                	sub    %eax,%ebx
80101e67:	89 d8                	mov    %ebx,%eax
80101e69:	39 c2                	cmp    %eax,%edx
80101e6b:	0f 46 c2             	cmovbe %edx,%eax
80101e6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e74:	8d 50 18             	lea    0x18(%eax),%edx
80101e77:	8b 45 10             	mov    0x10(%ebp),%eax
80101e7a:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e7f:	01 c2                	add    %eax,%edx
80101e81:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e84:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e88:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e8f:	89 04 24             	mov    %eax,(%esp)
80101e92:	e8 a2 44 00 00       	call   80106339 <memmove>
    brelse(bp);
80101e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e9a:	89 04 24             	mov    %eax,(%esp)
80101e9d:	e8 75 e3 ff ff       	call   80100217 <brelse>

  if(off + n > ip->size)
    n = ip->size - off;
 

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ea2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea5:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ea8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eab:	01 45 10             	add    %eax,0x10(%ebp)
80101eae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb1:	01 45 0c             	add    %eax,0xc(%ebp)
80101eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101eb7:	3b 45 14             	cmp    0x14(%ebp),%eax
80101eba:	0f 82 5e ff ff ff    	jb     80101e1e <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ec0:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101ec3:	83 c4 24             	add    $0x24,%esp
80101ec6:	5b                   	pop    %ebx
80101ec7:	5d                   	pop    %ebp
80101ec8:	c3                   	ret    

80101ec9 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ec9:	55                   	push   %ebp
80101eca:	89 e5                	mov    %esp,%ebp
80101ecc:	53                   	push   %ebx
80101ecd:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ed7:	66 83 f8 03          	cmp    $0x3,%ax
80101edb:	75 60                	jne    80101f3d <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101edd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee4:	66 85 c0             	test   %ax,%ax
80101ee7:	78 20                	js     80101f09 <writei+0x40>
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef0:	66 83 f8 09          	cmp    $0x9,%ax
80101ef4:	7f 13                	jg     80101f09 <writei+0x40>
80101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efd:	98                   	cwtl   
80101efe:	8b 04 c5 64 08 11 80 	mov    -0x7feef79c(,%eax,8),%eax
80101f05:	85 c0                	test   %eax,%eax
80101f07:	75 0a                	jne    80101f13 <writei+0x4a>
      return -1;
80101f09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f0e:	e9 46 01 00 00       	jmp    80102059 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80101f13:	8b 45 08             	mov    0x8(%ebp),%eax
80101f16:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f1a:	98                   	cwtl   
80101f1b:	8b 14 c5 64 08 11 80 	mov    -0x7feef79c(,%eax,8),%edx
80101f22:	8b 45 14             	mov    0x14(%ebp),%eax
80101f25:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f29:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f30:	8b 45 08             	mov    0x8(%ebp),%eax
80101f33:	89 04 24             	mov    %eax,(%esp)
80101f36:	ff d2                	call   *%edx
80101f38:	e9 1c 01 00 00       	jmp    80102059 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80101f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f40:	8b 40 18             	mov    0x18(%eax),%eax
80101f43:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f46:	72 0d                	jb     80101f55 <writei+0x8c>
80101f48:	8b 45 14             	mov    0x14(%ebp),%eax
80101f4b:	8b 55 10             	mov    0x10(%ebp),%edx
80101f4e:	01 d0                	add    %edx,%eax
80101f50:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f53:	73 0a                	jae    80101f5f <writei+0x96>
    return -1;
80101f55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f5a:	e9 fa 00 00 00       	jmp    80102059 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80101f5f:	8b 45 14             	mov    0x14(%ebp),%eax
80101f62:	8b 55 10             	mov    0x10(%ebp),%edx
80101f65:	01 d0                	add    %edx,%eax
80101f67:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f6c:	76 0a                	jbe    80101f78 <writei+0xaf>
    return -1;
80101f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f73:	e9 e1 00 00 00       	jmp    80102059 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f7f:	e9 a1 00 00 00       	jmp    80102025 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f84:	8b 45 10             	mov    0x10(%ebp),%eax
80101f87:	c1 e8 09             	shr    $0x9,%eax
80101f8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f91:	89 04 24             	mov    %eax,(%esp)
80101f94:	e8 71 fb ff ff       	call   80101b0a <bmap>
80101f99:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9c:	8b 12                	mov    (%edx),%edx
80101f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fa2:	89 14 24             	mov    %edx,(%esp)
80101fa5:	e8 fc e1 ff ff       	call   801001a6 <bread>
80101faa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fad:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb0:	89 c2                	mov    %eax,%edx
80101fb2:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101fb8:	b8 00 02 00 00       	mov    $0x200,%eax
80101fbd:	89 c1                	mov    %eax,%ecx
80101fbf:	29 d1                	sub    %edx,%ecx
80101fc1:	89 ca                	mov    %ecx,%edx
80101fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc6:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fc9:	89 cb                	mov    %ecx,%ebx
80101fcb:	29 c3                	sub    %eax,%ebx
80101fcd:	89 d8                	mov    %ebx,%eax
80101fcf:	39 c2                	cmp    %eax,%edx
80101fd1:	0f 46 c2             	cmovbe %edx,%eax
80101fd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fda:	8d 50 18             	lea    0x18(%eax),%edx
80101fdd:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe0:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fe5:	01 c2                	add    %eax,%edx
80101fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fea:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ff5:	89 14 24             	mov    %edx,(%esp)
80101ff8:	e8 3c 43 00 00       	call   80106339 <memmove>
    log_write(bp);
80101ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102000:	89 04 24             	mov    %eax,(%esp)
80102003:	e8 84 12 00 00       	call   8010328c <log_write>
    brelse(bp);
80102008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200b:	89 04 24             	mov    %eax,(%esp)
8010200e:	e8 04 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102013:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102016:	01 45 f4             	add    %eax,-0xc(%ebp)
80102019:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201c:	01 45 10             	add    %eax,0x10(%ebp)
8010201f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102022:	01 45 0c             	add    %eax,0xc(%ebp)
80102025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102028:	3b 45 14             	cmp    0x14(%ebp),%eax
8010202b:	0f 82 53 ff ff ff    	jb     80101f84 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102031:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102035:	74 1f                	je     80102056 <writei+0x18d>
80102037:	8b 45 08             	mov    0x8(%ebp),%eax
8010203a:	8b 40 18             	mov    0x18(%eax),%eax
8010203d:	3b 45 10             	cmp    0x10(%ebp),%eax
80102040:	73 14                	jae    80102056 <writei+0x18d>
    ip->size = off;
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	8b 55 10             	mov    0x10(%ebp),%edx
80102048:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	89 04 24             	mov    %eax,(%esp)
80102051:	e8 56 f6 ff ff       	call   801016ac <iupdate>
  }
  return n;
80102056:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102059:	83 c4 24             	add    $0x24,%esp
8010205c:	5b                   	pop    %ebx
8010205d:	5d                   	pop    %ebp
8010205e:	c3                   	ret    

8010205f <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010205f:	55                   	push   %ebp
80102060:	89 e5                	mov    %esp,%ebp
80102062:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102065:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010206c:	00 
8010206d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102070:	89 44 24 04          	mov    %eax,0x4(%esp)
80102074:	8b 45 08             	mov    0x8(%ebp),%eax
80102077:	89 04 24             	mov    %eax,(%esp)
8010207a:	e8 5e 43 00 00       	call   801063dd <strncmp>
}
8010207f:	c9                   	leave  
80102080:	c3                   	ret    

80102081 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102081:	55                   	push   %ebp
80102082:	89 e5                	mov    %esp,%ebp
80102084:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102087:	8b 45 08             	mov    0x8(%ebp),%eax
8010208a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010208e:	66 83 f8 01          	cmp    $0x1,%ax
80102092:	74 0c                	je     801020a0 <dirlookup+0x1f>
    panic("dirlookup not DIR");
80102094:	c7 04 24 e1 98 10 80 	movl   $0x801098e1,(%esp)
8010209b:	e8 9d e4 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020a7:	e9 87 00 00 00       	jmp    80102133 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020ac:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020b3:	00 
801020b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020b7:	89 44 24 08          	mov    %eax,0x8(%esp)
801020bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020be:	89 44 24 04          	mov    %eax,0x4(%esp)
801020c2:	8b 45 08             	mov    0x8(%ebp),%eax
801020c5:	89 04 24             	mov    %eax,(%esp)
801020c8:	e8 91 fc ff ff       	call   80101d5e <readi>
801020cd:	83 f8 10             	cmp    $0x10,%eax
801020d0:	74 0c                	je     801020de <dirlookup+0x5d>
      panic("dirlink read");
801020d2:	c7 04 24 f3 98 10 80 	movl   $0x801098f3,(%esp)
801020d9:	e8 5f e4 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801020de:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020e2:	66 85 c0             	test   %ax,%ax
801020e5:	74 47                	je     8010212e <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
801020e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ea:	83 c0 02             	add    $0x2,%eax
801020ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801020f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801020f4:	89 04 24             	mov    %eax,(%esp)
801020f7:	e8 63 ff ff ff       	call   8010205f <namecmp>
801020fc:	85 c0                	test   %eax,%eax
801020fe:	75 2f                	jne    8010212f <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102100:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102104:	74 08                	je     8010210e <dirlookup+0x8d>
        *poff = off;
80102106:	8b 45 10             	mov    0x10(%ebp),%eax
80102109:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010210c:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010210e:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102112:	0f b7 c0             	movzwl %ax,%eax
80102115:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102118:	8b 45 08             	mov    0x8(%ebp),%eax
8010211b:	8b 00                	mov    (%eax),%eax
8010211d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102120:	89 54 24 04          	mov    %edx,0x4(%esp)
80102124:	89 04 24             	mov    %eax,(%esp)
80102127:	e8 38 f6 ff ff       	call   80101764 <iget>
8010212c:	eb 19                	jmp    80102147 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010212e:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010212f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102133:	8b 45 08             	mov    0x8(%ebp),%eax
80102136:	8b 40 18             	mov    0x18(%eax),%eax
80102139:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010213c:	0f 87 6a ff ff ff    	ja     801020ac <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102142:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102147:	c9                   	leave  
80102148:	c3                   	ret    

80102149 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102149:	55                   	push   %ebp
8010214a:	89 e5                	mov    %esp,%ebp
8010214c:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010214f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102156:	00 
80102157:	8b 45 0c             	mov    0xc(%ebp),%eax
8010215a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010215e:	8b 45 08             	mov    0x8(%ebp),%eax
80102161:	89 04 24             	mov    %eax,(%esp)
80102164:	e8 18 ff ff ff       	call   80102081 <dirlookup>
80102169:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010216c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102170:	74 15                	je     80102187 <dirlink+0x3e>
    iput(ip);
80102172:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102175:	89 04 24             	mov    %eax,(%esp)
80102178:	e8 9e f8 ff ff       	call   80101a1b <iput>
    return -1;
8010217d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102182:	e9 b8 00 00 00       	jmp    8010223f <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102187:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010218e:	eb 44                	jmp    801021d4 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102193:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010219a:	00 
8010219b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010219f:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	89 04 24             	mov    %eax,(%esp)
801021ac:	e8 ad fb ff ff       	call   80101d5e <readi>
801021b1:	83 f8 10             	cmp    $0x10,%eax
801021b4:	74 0c                	je     801021c2 <dirlink+0x79>
      panic("dirlink read");
801021b6:	c7 04 24 f3 98 10 80 	movl   $0x801098f3,(%esp)
801021bd:	e8 7b e3 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801021c2:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021c6:	66 85 c0             	test   %ax,%ax
801021c9:	74 18                	je     801021e3 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021ce:	83 c0 10             	add    $0x10,%eax
801021d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021d7:	8b 45 08             	mov    0x8(%ebp),%eax
801021da:	8b 40 18             	mov    0x18(%eax),%eax
801021dd:	39 c2                	cmp    %eax,%edx
801021df:	72 af                	jb     80102190 <dirlink+0x47>
801021e1:	eb 01                	jmp    801021e4 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801021e3:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801021e4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021eb:	00 
801021ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801021ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801021f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021f6:	83 c0 02             	add    $0x2,%eax
801021f9:	89 04 24             	mov    %eax,(%esp)
801021fc:	e8 34 42 00 00       	call   80106435 <strncpy>
  de.inum = inum;
80102201:	8b 45 10             	mov    0x10(%ebp),%eax
80102204:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102208:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010220b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102212:	00 
80102213:	89 44 24 08          	mov    %eax,0x8(%esp)
80102217:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010221e:	8b 45 08             	mov    0x8(%ebp),%eax
80102221:	89 04 24             	mov    %eax,(%esp)
80102224:	e8 a0 fc ff ff       	call   80101ec9 <writei>
80102229:	83 f8 10             	cmp    $0x10,%eax
8010222c:	74 0c                	je     8010223a <dirlink+0xf1>
    panic("dirlink");
8010222e:	c7 04 24 00 99 10 80 	movl   $0x80109900,(%esp)
80102235:	e8 03 e3 ff ff       	call   8010053d <panic>
  
  return 0;
8010223a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010223f:	c9                   	leave  
80102240:	c3                   	ret    

80102241 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102241:	55                   	push   %ebp
80102242:	89 e5                	mov    %esp,%ebp
80102244:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102247:	eb 04                	jmp    8010224d <skipelem+0xc>
    path++;
80102249:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010224d:	8b 45 08             	mov    0x8(%ebp),%eax
80102250:	0f b6 00             	movzbl (%eax),%eax
80102253:	3c 2f                	cmp    $0x2f,%al
80102255:	74 f2                	je     80102249 <skipelem+0x8>
    path++;
  if(*path == 0)
80102257:	8b 45 08             	mov    0x8(%ebp),%eax
8010225a:	0f b6 00             	movzbl (%eax),%eax
8010225d:	84 c0                	test   %al,%al
8010225f:	75 0a                	jne    8010226b <skipelem+0x2a>
    return 0;
80102261:	b8 00 00 00 00       	mov    $0x0,%eax
80102266:	e9 86 00 00 00       	jmp    801022f1 <skipelem+0xb0>
  s = path;
8010226b:	8b 45 08             	mov    0x8(%ebp),%eax
8010226e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102271:	eb 04                	jmp    80102277 <skipelem+0x36>
    path++;
80102273:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102277:	8b 45 08             	mov    0x8(%ebp),%eax
8010227a:	0f b6 00             	movzbl (%eax),%eax
8010227d:	3c 2f                	cmp    $0x2f,%al
8010227f:	74 0a                	je     8010228b <skipelem+0x4a>
80102281:	8b 45 08             	mov    0x8(%ebp),%eax
80102284:	0f b6 00             	movzbl (%eax),%eax
80102287:	84 c0                	test   %al,%al
80102289:	75 e8                	jne    80102273 <skipelem+0x32>
    path++;
  len = path - s;
8010228b:	8b 55 08             	mov    0x8(%ebp),%edx
8010228e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102291:	89 d1                	mov    %edx,%ecx
80102293:	29 c1                	sub    %eax,%ecx
80102295:	89 c8                	mov    %ecx,%eax
80102297:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010229a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010229e:	7e 1c                	jle    801022bc <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801022a0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022a7:	00 
801022a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801022af:	8b 45 0c             	mov    0xc(%ebp),%eax
801022b2:	89 04 24             	mov    %eax,(%esp)
801022b5:	e8 7f 40 00 00       	call   80106339 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022ba:	eb 28                	jmp    801022e4 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801022c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801022cd:	89 04 24             	mov    %eax,(%esp)
801022d0:	e8 64 40 00 00       	call   80106339 <memmove>
    name[len] = 0;
801022d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022d8:	03 45 0c             	add    0xc(%ebp),%eax
801022db:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022de:	eb 04                	jmp    801022e4 <skipelem+0xa3>
    path++;
801022e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022e4:	8b 45 08             	mov    0x8(%ebp),%eax
801022e7:	0f b6 00             	movzbl (%eax),%eax
801022ea:	3c 2f                	cmp    $0x2f,%al
801022ec:	74 f2                	je     801022e0 <skipelem+0x9f>
    path++;
  return path;
801022ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022f1:	c9                   	leave  
801022f2:	c3                   	ret    

801022f3 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022f3:	55                   	push   %ebp
801022f4:	89 e5                	mov    %esp,%ebp
801022f6:	83 ec 28             	sub    $0x28,%esp
//   cprintf("namex path %s\n",path);
  struct inode *ip, *next;
  if(*path == '/')
801022f9:	8b 45 08             	mov    0x8(%ebp),%eax
801022fc:	0f b6 00             	movzbl (%eax),%eax
801022ff:	3c 2f                	cmp    $0x2f,%al
80102301:	75 1c                	jne    8010231f <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102303:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010230a:	00 
8010230b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102312:	e8 4d f4 ff ff       	call   80101764 <iget>
80102317:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);
  
  
//   cprintf("ip->sz: %s\n",path);
  while((path = skipelem(path, name)) != 0){
8010231a:	e9 af 00 00 00       	jmp    801023ce <namex+0xdb>
//   cprintf("namex path %s\n",path);
  struct inode *ip, *next;
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010231f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102325:	8b 40 68             	mov    0x68(%eax),%eax
80102328:	89 04 24             	mov    %eax,(%esp)
8010232b:	e8 06 f5 ff ff       	call   80101836 <idup>
80102330:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  
//   cprintf("ip->sz: %s\n",path);
  while((path = skipelem(path, name)) != 0){
80102333:	e9 96 00 00 00       	jmp    801023ce <namex+0xdb>
    ilock(ip);
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	89 04 24             	mov    %eax,(%esp)
8010233e:	e8 25 f5 ff ff       	call   80101868 <ilock>
    if(ip->type != T_DIR){
80102343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102346:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010234a:	66 83 f8 01          	cmp    $0x1,%ax
8010234e:	74 15                	je     80102365 <namex+0x72>
      iunlockput(ip);
80102350:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102353:	89 04 24             	mov    %eax,(%esp)
80102356:	e8 91 f7 ff ff       	call   80101aec <iunlockput>
      return 0;
8010235b:	b8 00 00 00 00       	mov    $0x0,%eax
80102360:	e9 a3 00 00 00       	jmp    80102408 <namex+0x115>
    }
    //cprintf("namex_if- nameiparent: %x. *path: %s\n",nameiparent,*path);
    if(nameiparent && *path == '\0'){
80102365:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102369:	74 1d                	je     80102388 <namex+0x95>
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	0f b6 00             	movzbl (%eax),%eax
80102371:	84 c0                	test   %al,%al
80102373:	75 13                	jne    80102388 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102378:	89 04 24             	mov    %eax,(%esp)
8010237b:	e8 36 f6 ff ff       	call   801019b6 <iunlock>
      return ip;
80102380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102383:	e9 80 00 00 00       	jmp    80102408 <namex+0x115>
    }
    //cprintf("namex_dir_lookup- ip: %d. name: %s\n",ip,name);
    if((next = dirlookup(ip, name, 0)) == 0){
80102388:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010238f:	00 
80102390:	8b 45 10             	mov    0x10(%ebp),%eax
80102393:	89 44 24 04          	mov    %eax,0x4(%esp)
80102397:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010239a:	89 04 24             	mov    %eax,(%esp)
8010239d:	e8 df fc ff ff       	call   80102081 <dirlookup>
801023a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023a9:	75 12                	jne    801023bd <namex+0xca>
      iunlockput(ip);
801023ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ae:	89 04 24             	mov    %eax,(%esp)
801023b1:	e8 36 f7 ff ff       	call   80101aec <iunlockput>
      return 0;
801023b6:	b8 00 00 00 00       	mov    $0x0,%eax
801023bb:	eb 4b                	jmp    80102408 <namex+0x115>
    }
    //cprintf("namex_iunlockput- ip: %d. \n",ip);
    iunlockput(ip);
801023bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c0:	89 04 24             	mov    %eax,(%esp)
801023c3:	e8 24 f7 ff ff       	call   80101aec <iunlockput>
    ip = next;
801023c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);
  
  
//   cprintf("ip->sz: %s\n",path);
  while((path = skipelem(path, name)) != 0){
801023ce:	8b 45 10             	mov    0x10(%ebp),%eax
801023d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801023d5:	8b 45 08             	mov    0x8(%ebp),%eax
801023d8:	89 04 24             	mov    %eax,(%esp)
801023db:	e8 61 fe ff ff       	call   80102241 <skipelem>
801023e0:	89 45 08             	mov    %eax,0x8(%ebp)
801023e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023e7:	0f 85 4b ff ff ff    	jne    80102338 <namex+0x45>
    }
    //cprintf("namex_iunlockput- ip: %d. \n",ip);
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023f1:	74 12                	je     80102405 <namex+0x112>
    iput(ip);
801023f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f6:	89 04 24             	mov    %eax,(%esp)
801023f9:	e8 1d f6 ff ff       	call   80101a1b <iput>
    return 0;
801023fe:	b8 00 00 00 00       	mov    $0x0,%eax
80102403:	eb 03                	jmp    80102408 <namex+0x115>
  }
  return ip;
80102405:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102408:	c9                   	leave  
80102409:	c3                   	ret    

8010240a <namei>:

struct inode*
namei(char *path)
{
8010240a:	55                   	push   %ebp
8010240b:	89 e5                	mov    %esp,%ebp
8010240d:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102410:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102413:	89 44 24 08          	mov    %eax,0x8(%esp)
80102417:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010241e:	00 
8010241f:	8b 45 08             	mov    0x8(%ebp),%eax
80102422:	89 04 24             	mov    %eax,(%esp)
80102425:	e8 c9 fe ff ff       	call   801022f3 <namex>
}
8010242a:	c9                   	leave  
8010242b:	c3                   	ret    

8010242c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010242c:	55                   	push   %ebp
8010242d:	89 e5                	mov    %esp,%ebp
8010242f:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102432:	8b 45 0c             	mov    0xc(%ebp),%eax
80102435:	89 44 24 08          	mov    %eax,0x8(%esp)
80102439:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102440:	00 
80102441:	8b 45 08             	mov    0x8(%ebp),%eax
80102444:	89 04 24             	mov    %eax,(%esp)
80102447:	e8 a7 fe ff ff       	call   801022f3 <namex>
}
8010244c:	c9                   	leave  
8010244d:	c3                   	ret    
	...

80102450 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102450:	55                   	push   %ebp
80102451:	89 e5                	mov    %esp,%ebp
80102453:	53                   	push   %ebx
80102454:	83 ec 14             	sub    $0x14,%esp
80102457:	8b 45 08             	mov    0x8(%ebp),%eax
8010245a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010245e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102462:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102466:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010246a:	ec                   	in     (%dx),%al
8010246b:	89 c3                	mov    %eax,%ebx
8010246d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102470:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102474:	83 c4 14             	add    $0x14,%esp
80102477:	5b                   	pop    %ebx
80102478:	5d                   	pop    %ebp
80102479:	c3                   	ret    

8010247a <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010247a:	55                   	push   %ebp
8010247b:	89 e5                	mov    %esp,%ebp
8010247d:	57                   	push   %edi
8010247e:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010247f:	8b 55 08             	mov    0x8(%ebp),%edx
80102482:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102485:	8b 45 10             	mov    0x10(%ebp),%eax
80102488:	89 cb                	mov    %ecx,%ebx
8010248a:	89 df                	mov    %ebx,%edi
8010248c:	89 c1                	mov    %eax,%ecx
8010248e:	fc                   	cld    
8010248f:	f3 6d                	rep insl (%dx),%es:(%edi)
80102491:	89 c8                	mov    %ecx,%eax
80102493:	89 fb                	mov    %edi,%ebx
80102495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102498:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010249b:	5b                   	pop    %ebx
8010249c:	5f                   	pop    %edi
8010249d:	5d                   	pop    %ebp
8010249e:	c3                   	ret    

8010249f <outb>:

static inline void
outb(ushort port, uchar data)
{
8010249f:	55                   	push   %ebp
801024a0:	89 e5                	mov    %esp,%ebp
801024a2:	83 ec 08             	sub    $0x8,%esp
801024a5:	8b 55 08             	mov    0x8(%ebp),%edx
801024a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024af:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024b2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024b6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024ba:	ee                   	out    %al,(%dx)
}
801024bb:	c9                   	leave  
801024bc:	c3                   	ret    

801024bd <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024bd:	55                   	push   %ebp
801024be:	89 e5                	mov    %esp,%ebp
801024c0:	56                   	push   %esi
801024c1:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024c2:	8b 55 08             	mov    0x8(%ebp),%edx
801024c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024c8:	8b 45 10             	mov    0x10(%ebp),%eax
801024cb:	89 cb                	mov    %ecx,%ebx
801024cd:	89 de                	mov    %ebx,%esi
801024cf:	89 c1                	mov    %eax,%ecx
801024d1:	fc                   	cld    
801024d2:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024d4:	89 c8                	mov    %ecx,%eax
801024d6:	89 f3                	mov    %esi,%ebx
801024d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024db:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024de:	5b                   	pop    %ebx
801024df:	5e                   	pop    %esi
801024e0:	5d                   	pop    %ebp
801024e1:	c3                   	ret    

801024e2 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801024e2:	55                   	push   %ebp
801024e3:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801024e5:	fa                   	cli    
}
801024e6:	5d                   	pop    %ebp
801024e7:	c3                   	ret    

801024e8 <sti>:

static inline void
sti(void)
{
801024e8:	55                   	push   %ebp
801024e9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801024eb:	fb                   	sti    
}
801024ec:	5d                   	pop    %ebp
801024ed:	c3                   	ret    

801024ee <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024ee:	55                   	push   %ebp
801024ef:	89 e5                	mov    %esp,%ebp
801024f1:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024f4:	90                   	nop
801024f5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024fc:	e8 4f ff ff ff       	call   80102450 <inb>
80102501:	0f b6 c0             	movzbl %al,%eax
80102504:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102507:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010250a:	25 c0 00 00 00       	and    $0xc0,%eax
8010250f:	83 f8 40             	cmp    $0x40,%eax
80102512:	75 e1                	jne    801024f5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102514:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102518:	74 11                	je     8010252b <idewait+0x3d>
8010251a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010251d:	83 e0 21             	and    $0x21,%eax
80102520:	85 c0                	test   %eax,%eax
80102522:	74 07                	je     8010252b <idewait+0x3d>
    return -1;
80102524:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102529:	eb 05                	jmp    80102530 <idewait+0x42>
  return 0;
8010252b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102530:	c9                   	leave  
80102531:	c3                   	ret    

80102532 <ideinit>:

void
ideinit(void)
{
80102532:	55                   	push   %ebp
80102533:	89 e5                	mov    %esp,%ebp
80102535:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102538:	c7 44 24 04 08 99 10 	movl   $0x80109908,0x4(%esp)
8010253f:	80 
80102540:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80102547:	e8 96 3a 00 00       	call   80105fe2 <initlock>
  picenable(IRQ_IDE);
8010254c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102553:	e8 39 15 00 00       	call   80103a91 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102558:	a1 60 1f 11 80       	mov    0x80111f60,%eax
8010255d:	83 e8 01             	sub    $0x1,%eax
80102560:	89 44 24 04          	mov    %eax,0x4(%esp)
80102564:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010256b:	e8 fa 03 00 00       	call   8010296a <ioapicenable>
  idewait(0);
80102570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102577:	e8 72 ff ff ff       	call   801024ee <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010257c:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102583:	00 
80102584:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010258b:	e8 0f ff ff ff       	call   8010249f <outb>
  for(i=0; i<1000; i++){
80102590:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102597:	eb 20                	jmp    801025b9 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102599:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025a0:	e8 ab fe ff ff       	call   80102450 <inb>
801025a5:	84 c0                	test   %al,%al
801025a7:	74 0c                	je     801025b5 <ideinit+0x83>
      havedisk1 = 1;
801025a9:	c7 05 98 d6 10 80 01 	movl   $0x1,0x8010d698
801025b0:	00 00 00 
      break;
801025b3:	eb 0d                	jmp    801025c2 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025b9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025c0:	7e d7                	jle    80102599 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025c2:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025c9:	00 
801025ca:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025d1:	e8 c9 fe ff ff       	call   8010249f <outb>
}
801025d6:	c9                   	leave  
801025d7:	c3                   	ret    

801025d8 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025d8:	55                   	push   %ebp
801025d9:	89 e5                	mov    %esp,%ebp
801025db:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025e2:	75 0c                	jne    801025f0 <idestart+0x18>
    panic("idestart");
801025e4:	c7 04 24 0c 99 10 80 	movl   $0x8010990c,(%esp)
801025eb:	e8 4d df ff ff       	call   8010053d <panic>

  idewait(0);
801025f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025f7:	e8 f2 fe ff ff       	call   801024ee <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102603:	00 
80102604:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010260b:	e8 8f fe ff ff       	call   8010249f <outb>
  outb(0x1f2, 1);  // number of sectors
80102610:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102617:	00 
80102618:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010261f:	e8 7b fe ff ff       	call   8010249f <outb>
  outb(0x1f3, b->sector & 0xff);
80102624:	8b 45 08             	mov    0x8(%ebp),%eax
80102627:	8b 40 08             	mov    0x8(%eax),%eax
8010262a:	0f b6 c0             	movzbl %al,%eax
8010262d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102631:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102638:	e8 62 fe ff ff       	call   8010249f <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010263d:	8b 45 08             	mov    0x8(%ebp),%eax
80102640:	8b 40 08             	mov    0x8(%eax),%eax
80102643:	c1 e8 08             	shr    $0x8,%eax
80102646:	0f b6 c0             	movzbl %al,%eax
80102649:	89 44 24 04          	mov    %eax,0x4(%esp)
8010264d:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102654:	e8 46 fe ff ff       	call   8010249f <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102659:	8b 45 08             	mov    0x8(%ebp),%eax
8010265c:	8b 40 08             	mov    0x8(%eax),%eax
8010265f:	c1 e8 10             	shr    $0x10,%eax
80102662:	0f b6 c0             	movzbl %al,%eax
80102665:	89 44 24 04          	mov    %eax,0x4(%esp)
80102669:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102670:	e8 2a fe ff ff       	call   8010249f <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102675:	8b 45 08             	mov    0x8(%ebp),%eax
80102678:	8b 40 04             	mov    0x4(%eax),%eax
8010267b:	83 e0 01             	and    $0x1,%eax
8010267e:	89 c2                	mov    %eax,%edx
80102680:	c1 e2 04             	shl    $0x4,%edx
80102683:	8b 45 08             	mov    0x8(%ebp),%eax
80102686:	8b 40 08             	mov    0x8(%eax),%eax
80102689:	c1 e8 18             	shr    $0x18,%eax
8010268c:	83 e0 0f             	and    $0xf,%eax
8010268f:	09 d0                	or     %edx,%eax
80102691:	83 c8 e0             	or     $0xffffffe0,%eax
80102694:	0f b6 c0             	movzbl %al,%eax
80102697:	89 44 24 04          	mov    %eax,0x4(%esp)
8010269b:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026a2:	e8 f8 fd ff ff       	call   8010249f <outb>
  if(b->flags & B_DIRTY){
801026a7:	8b 45 08             	mov    0x8(%ebp),%eax
801026aa:	8b 00                	mov    (%eax),%eax
801026ac:	83 e0 04             	and    $0x4,%eax
801026af:	85 c0                	test   %eax,%eax
801026b1:	74 34                	je     801026e7 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026b3:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026ba:	00 
801026bb:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026c2:	e8 d8 fd ff ff       	call   8010249f <outb>
    outsl(0x1f0, b->data, 512/4);
801026c7:	8b 45 08             	mov    0x8(%ebp),%eax
801026ca:	83 c0 18             	add    $0x18,%eax
801026cd:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026d4:	00 
801026d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d9:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026e0:	e8 d8 fd ff ff       	call   801024bd <outsl>
801026e5:	eb 14                	jmp    801026fb <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026e7:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026ee:	00 
801026ef:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026f6:	e8 a4 fd ff ff       	call   8010249f <outb>
  }
}
801026fb:	c9                   	leave  
801026fc:	c3                   	ret    

801026fd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026fd:	55                   	push   %ebp
801026fe:	89 e5                	mov    %esp,%ebp
80102700:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102703:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010270a:	e8 f4 38 00 00       	call   80106003 <acquire>
  if((b = idequeue) == 0){
8010270f:	a1 94 d6 10 80       	mov    0x8010d694,%eax
80102714:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010271b:	75 11                	jne    8010272e <ideintr+0x31>
    release(&idelock);
8010271d:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80102724:	e8 52 39 00 00       	call   8010607b <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102729:	e9 85 00 00 00       	jmp    801027b3 <ideintr+0xb6>
  }
  idequeue = b->qnext;
8010272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102731:	8b 40 14             	mov    0x14(%eax),%eax
80102734:	a3 94 d6 10 80       	mov    %eax,0x8010d694

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273c:	8b 00                	mov    (%eax),%eax
8010273e:	83 e0 04             	and    $0x4,%eax
80102741:	85 c0                	test   %eax,%eax
80102743:	75 2e                	jne    80102773 <ideintr+0x76>
80102745:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010274c:	e8 9d fd ff ff       	call   801024ee <idewait>
80102751:	85 c0                	test   %eax,%eax
80102753:	78 1e                	js     80102773 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102758:	83 c0 18             	add    $0x18,%eax
8010275b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102762:	00 
80102763:	89 44 24 04          	mov    %eax,0x4(%esp)
80102767:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010276e:	e8 07 fd ff ff       	call   8010247a <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102776:	8b 00                	mov    (%eax),%eax
80102778:	89 c2                	mov    %eax,%edx
8010277a:	83 ca 02             	or     $0x2,%edx
8010277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102780:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102785:	8b 00                	mov    (%eax),%eax
80102787:	89 c2                	mov    %eax,%edx
80102789:	83 e2 fb             	and    $0xfffffffb,%edx
8010278c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278f:	89 10                	mov    %edx,(%eax)
  //wakeup(b);
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102791:	a1 94 d6 10 80       	mov    0x8010d694,%eax
80102796:	85 c0                	test   %eax,%eax
80102798:	74 0d                	je     801027a7 <ideintr+0xaa>
    idestart(idequeue);
8010279a:	a1 94 d6 10 80       	mov    0x8010d694,%eax
8010279f:	89 04 24             	mov    %eax,(%esp)
801027a2:	e8 31 fe ff ff       	call   801025d8 <idestart>

  release(&idelock);
801027a7:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801027ae:	e8 c8 38 00 00       	call   8010607b <release>
}
801027b3:	c9                   	leave  
801027b4:	c3                   	ret    

801027b5 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027b5:	55                   	push   %ebp
801027b6:	89 e5                	mov    %esp,%ebp
801027b8:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027bb:	8b 45 08             	mov    0x8(%ebp),%eax
801027be:	8b 00                	mov    (%eax),%eax
801027c0:	83 e0 01             	and    $0x1,%eax
801027c3:	85 c0                	test   %eax,%eax
801027c5:	75 0c                	jne    801027d3 <iderw+0x1e>
    panic("iderw: buf not busy");
801027c7:	c7 04 24 15 99 10 80 	movl   $0x80109915,(%esp)
801027ce:	e8 6a dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027d3:	8b 45 08             	mov    0x8(%ebp),%eax
801027d6:	8b 00                	mov    (%eax),%eax
801027d8:	83 e0 06             	and    $0x6,%eax
801027db:	83 f8 02             	cmp    $0x2,%eax
801027de:	75 0c                	jne    801027ec <iderw+0x37>
    panic("iderw: nothing to do");
801027e0:	c7 04 24 29 99 10 80 	movl   $0x80109929,(%esp)
801027e7:	e8 51 dd ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
801027ec:	8b 45 08             	mov    0x8(%ebp),%eax
801027ef:	8b 40 04             	mov    0x4(%eax),%eax
801027f2:	85 c0                	test   %eax,%eax
801027f4:	74 15                	je     8010280b <iderw+0x56>
801027f6:	a1 98 d6 10 80       	mov    0x8010d698,%eax
801027fb:	85 c0                	test   %eax,%eax
801027fd:	75 0c                	jne    8010280b <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027ff:	c7 04 24 3e 99 10 80 	movl   $0x8010993e,(%esp)
80102806:	e8 32 dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC: acquire-lock
8010280b:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80102812:	e8 ec 37 00 00       	call   80106003 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102817:	8b 45 08             	mov    0x8(%ebp),%eax
8010281a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC: insert-queue
80102821:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
80102828:	eb 0b                	jmp    80102835 <iderw+0x80>
8010282a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010282d:	8b 00                	mov    (%eax),%eax
8010282f:	83 c0 14             	add    $0x14,%eax
80102832:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102838:	8b 00                	mov    (%eax),%eax
8010283a:	85 c0                	test   %eax,%eax
8010283c:	75 ec                	jne    8010282a <iderw+0x75>
    ;
  *pp = b;
8010283e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102841:	8b 55 08             	mov    0x8(%ebp),%edx
80102844:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102846:	a1 94 d6 10 80       	mov    0x8010d694,%eax
8010284b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010284e:	75 0b                	jne    8010285b <iderw+0xa6>
    idestart(b);
80102850:	8b 45 08             	mov    0x8(%ebp),%eax
80102853:	89 04 24             	mov    %eax,(%esp)
80102856:	e8 7d fd ff ff       	call   801025d8 <idestart>
  
  // Wait for request to finish.
  release(&idelock);
8010285b:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80102862:	e8 14 38 00 00       	call   8010607b <release>
  sti();
80102867:	e8 7c fc ff ff       	call   801024e8 <sti>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010286c:	90                   	nop
8010286d:	8b 45 08             	mov    0x8(%ebp),%eax
80102870:	8b 00                	mov    (%eax),%eax
80102872:	83 e0 06             	and    $0x6,%eax
80102875:	83 f8 02             	cmp    $0x2,%eax
80102878:	75 f3                	jne    8010286d <iderw+0xb8>
    //cprintf("loop\n");
    //sleep(b, &idelock); //busy wait
  }
  cli();
8010287a:	e8 63 fc ff ff       	call   801024e2 <cli>
}
8010287f:	c9                   	leave  
80102880:	c3                   	ret    
80102881:	00 00                	add    %al,(%eax)
	...

80102884 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102884:	55                   	push   %ebp
80102885:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102887:	a1 94 18 11 80       	mov    0x80111894,%eax
8010288c:	8b 55 08             	mov    0x8(%ebp),%edx
8010288f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102891:	a1 94 18 11 80       	mov    0x80111894,%eax
80102896:	8b 40 10             	mov    0x10(%eax),%eax
}
80102899:	5d                   	pop    %ebp
8010289a:	c3                   	ret    

8010289b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010289b:	55                   	push   %ebp
8010289c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010289e:	a1 94 18 11 80       	mov    0x80111894,%eax
801028a3:	8b 55 08             	mov    0x8(%ebp),%edx
801028a6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028a8:	a1 94 18 11 80       	mov    0x80111894,%eax
801028ad:	8b 55 0c             	mov    0xc(%ebp),%edx
801028b0:	89 50 10             	mov    %edx,0x10(%eax)
}
801028b3:	5d                   	pop    %ebp
801028b4:	c3                   	ret    

801028b5 <ioapicinit>:

void
ioapicinit(void)
{
801028b5:	55                   	push   %ebp
801028b6:	89 e5                	mov    %esp,%ebp
801028b8:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028bb:	a1 64 19 11 80       	mov    0x80111964,%eax
801028c0:	85 c0                	test   %eax,%eax
801028c2:	0f 84 9f 00 00 00    	je     80102967 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801028c8:	c7 05 94 18 11 80 00 	movl   $0xfec00000,0x80111894
801028cf:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028d9:	e8 a6 ff ff ff       	call   80102884 <ioapicread>
801028de:	c1 e8 10             	shr    $0x10,%eax
801028e1:	25 ff 00 00 00       	and    $0xff,%eax
801028e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801028e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028f0:	e8 8f ff ff ff       	call   80102884 <ioapicread>
801028f5:	c1 e8 18             	shr    $0x18,%eax
801028f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801028fb:	0f b6 05 60 19 11 80 	movzbl 0x80111960,%eax
80102902:	0f b6 c0             	movzbl %al,%eax
80102905:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102908:	74 0c                	je     80102916 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010290a:	c7 04 24 5c 99 10 80 	movl   $0x8010995c,(%esp)
80102911:	e8 8b da ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102916:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010291d:	eb 3e                	jmp    8010295d <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010291f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102922:	83 c0 20             	add    $0x20,%eax
80102925:	0d 00 00 01 00       	or     $0x10000,%eax
8010292a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010292d:	83 c2 08             	add    $0x8,%edx
80102930:	01 d2                	add    %edx,%edx
80102932:	89 44 24 04          	mov    %eax,0x4(%esp)
80102936:	89 14 24             	mov    %edx,(%esp)
80102939:	e8 5d ff ff ff       	call   8010289b <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010293e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102941:	83 c0 08             	add    $0x8,%eax
80102944:	01 c0                	add    %eax,%eax
80102946:	83 c0 01             	add    $0x1,%eax
80102949:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102950:	00 
80102951:	89 04 24             	mov    %eax,(%esp)
80102954:	e8 42 ff ff ff       	call   8010289b <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102959:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010295d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102960:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102963:	7e ba                	jle    8010291f <ioapicinit+0x6a>
80102965:	eb 01                	jmp    80102968 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102967:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102968:	c9                   	leave  
80102969:	c3                   	ret    

8010296a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010296a:	55                   	push   %ebp
8010296b:	89 e5                	mov    %esp,%ebp
8010296d:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102970:	a1 64 19 11 80       	mov    0x80111964,%eax
80102975:	85 c0                	test   %eax,%eax
80102977:	74 39                	je     801029b2 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102979:	8b 45 08             	mov    0x8(%ebp),%eax
8010297c:	83 c0 20             	add    $0x20,%eax
8010297f:	8b 55 08             	mov    0x8(%ebp),%edx
80102982:	83 c2 08             	add    $0x8,%edx
80102985:	01 d2                	add    %edx,%edx
80102987:	89 44 24 04          	mov    %eax,0x4(%esp)
8010298b:	89 14 24             	mov    %edx,(%esp)
8010298e:	e8 08 ff ff ff       	call   8010289b <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102993:	8b 45 0c             	mov    0xc(%ebp),%eax
80102996:	c1 e0 18             	shl    $0x18,%eax
80102999:	8b 55 08             	mov    0x8(%ebp),%edx
8010299c:	83 c2 08             	add    $0x8,%edx
8010299f:	01 d2                	add    %edx,%edx
801029a1:	83 c2 01             	add    $0x1,%edx
801029a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801029a8:	89 14 24             	mov    %edx,(%esp)
801029ab:	e8 eb fe ff ff       	call   8010289b <ioapicwrite>
801029b0:	eb 01                	jmp    801029b3 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801029b2:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801029b3:	c9                   	leave  
801029b4:	c3                   	ret    
801029b5:	00 00                	add    %al,(%eax)
	...

801029b8 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029b8:	55                   	push   %ebp
801029b9:	89 e5                	mov    %esp,%ebp
801029bb:	8b 45 08             	mov    0x8(%ebp),%eax
801029be:	05 00 00 00 80       	add    $0x80000000,%eax
801029c3:	5d                   	pop    %ebp
801029c4:	c3                   	ret    

801029c5 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029c5:	55                   	push   %ebp
801029c6:	89 e5                	mov    %esp,%ebp
801029c8:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029cb:	c7 44 24 04 8e 99 10 	movl   $0x8010998e,0x4(%esp)
801029d2:	80 
801029d3:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
801029da:	e8 03 36 00 00       	call   80105fe2 <initlock>
  kmem.use_lock = 0;
801029df:	c7 05 d4 18 11 80 00 	movl   $0x0,0x801118d4
801029e6:	00 00 00 
  freerange(vstart, vend);
801029e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f0:	8b 45 08             	mov    0x8(%ebp),%eax
801029f3:	89 04 24             	mov    %eax,(%esp)
801029f6:	e8 26 00 00 00       	call   80102a21 <freerange>
}
801029fb:	c9                   	leave  
801029fc:	c3                   	ret    

801029fd <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801029fd:	55                   	push   %ebp
801029fe:	89 e5                	mov    %esp,%ebp
80102a00:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a03:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a06:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0d:	89 04 24             	mov    %eax,(%esp)
80102a10:	e8 0c 00 00 00       	call   80102a21 <freerange>
  kmem.use_lock = 1;
80102a15:	c7 05 d4 18 11 80 01 	movl   $0x1,0x801118d4
80102a1c:	00 00 00 
}
80102a1f:	c9                   	leave  
80102a20:	c3                   	ret    

80102a21 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a21:	55                   	push   %ebp
80102a22:	89 e5                	mov    %esp,%ebp
80102a24:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a27:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a37:	eb 12                	jmp    80102a4b <freerange+0x2a>
    kfree(p);
80102a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3c:	89 04 24             	mov    %eax,(%esp)
80102a3f:	e8 16 00 00 00       	call   80102a5a <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a44:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4e:	05 00 10 00 00       	add    $0x1000,%eax
80102a53:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a56:	76 e1                	jbe    80102a39 <freerange+0x18>
    kfree(p);
}
80102a58:	c9                   	leave  
80102a59:	c3                   	ret    

80102a5a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a5a:	55                   	push   %ebp
80102a5b:	89 e5                	mov    %esp,%ebp
80102a5d:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a60:	8b 45 08             	mov    0x8(%ebp),%eax
80102a63:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a68:	85 c0                	test   %eax,%eax
80102a6a:	75 1b                	jne    80102a87 <kfree+0x2d>
80102a6c:	81 7d 08 9c 7a 18 80 	cmpl   $0x80187a9c,0x8(%ebp)
80102a73:	72 12                	jb     80102a87 <kfree+0x2d>
80102a75:	8b 45 08             	mov    0x8(%ebp),%eax
80102a78:	89 04 24             	mov    %eax,(%esp)
80102a7b:	e8 38 ff ff ff       	call   801029b8 <v2p>
80102a80:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a85:	76 0c                	jbe    80102a93 <kfree+0x39>
    panic("kfree");
80102a87:	c7 04 24 93 99 10 80 	movl   $0x80109993,(%esp)
80102a8e:	e8 aa da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a93:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a9a:	00 
80102a9b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aa2:	00 
80102aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa6:	89 04 24             	mov    %eax,(%esp)
80102aa9:	e8 b8 37 00 00       	call   80106266 <memset>

  if(kmem.use_lock)
80102aae:	a1 d4 18 11 80       	mov    0x801118d4,%eax
80102ab3:	85 c0                	test   %eax,%eax
80102ab5:	74 0c                	je     80102ac3 <kfree+0x69>
    acquire(&kmem.lock);
80102ab7:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80102abe:	e8 40 35 00 00       	call   80106003 <acquire>
  r = (struct run*)v;
80102ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ac6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ac9:	8b 15 d8 18 11 80    	mov    0x801118d8,%edx
80102acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad2:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad7:	a3 d8 18 11 80       	mov    %eax,0x801118d8
  if(kmem.use_lock)
80102adc:	a1 d4 18 11 80       	mov    0x801118d4,%eax
80102ae1:	85 c0                	test   %eax,%eax
80102ae3:	74 0c                	je     80102af1 <kfree+0x97>
    release(&kmem.lock);
80102ae5:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80102aec:	e8 8a 35 00 00       	call   8010607b <release>
}
80102af1:	c9                   	leave  
80102af2:	c3                   	ret    

80102af3 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102af3:	55                   	push   %ebp
80102af4:	89 e5                	mov    %esp,%ebp
80102af6:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102af9:	a1 d4 18 11 80       	mov    0x801118d4,%eax
80102afe:	85 c0                	test   %eax,%eax
80102b00:	74 0c                	je     80102b0e <kalloc+0x1b>
    acquire(&kmem.lock);
80102b02:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80102b09:	e8 f5 34 00 00       	call   80106003 <acquire>
  r = kmem.freelist;
80102b0e:	a1 d8 18 11 80       	mov    0x801118d8,%eax
80102b13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b16:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b1a:	74 0a                	je     80102b26 <kalloc+0x33>
    kmem.freelist = r->next;
80102b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1f:	8b 00                	mov    (%eax),%eax
80102b21:	a3 d8 18 11 80       	mov    %eax,0x801118d8
  if(kmem.use_lock)
80102b26:	a1 d4 18 11 80       	mov    0x801118d4,%eax
80102b2b:	85 c0                	test   %eax,%eax
80102b2d:	74 0c                	je     80102b3b <kalloc+0x48>
    release(&kmem.lock);
80102b2f:	c7 04 24 a0 18 11 80 	movl   $0x801118a0,(%esp)
80102b36:	e8 40 35 00 00       	call   8010607b <release>
  return (char*)r;
80102b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b3e:	c9                   	leave  
80102b3f:	c3                   	ret    

80102b40 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b40:	55                   	push   %ebp
80102b41:	89 e5                	mov    %esp,%ebp
80102b43:	53                   	push   %ebx
80102b44:	83 ec 14             	sub    $0x14,%esp
80102b47:	8b 45 08             	mov    0x8(%ebp),%eax
80102b4a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b4e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102b52:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102b56:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102b5a:	ec                   	in     (%dx),%al
80102b5b:	89 c3                	mov    %eax,%ebx
80102b5d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102b60:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102b64:	83 c4 14             	add    $0x14,%esp
80102b67:	5b                   	pop    %ebx
80102b68:	5d                   	pop    %ebp
80102b69:	c3                   	ret    

80102b6a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b6a:	55                   	push   %ebp
80102b6b:	89 e5                	mov    %esp,%ebp
80102b6d:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b70:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b77:	e8 c4 ff ff ff       	call   80102b40 <inb>
80102b7c:	0f b6 c0             	movzbl %al,%eax
80102b7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b85:	83 e0 01             	and    $0x1,%eax
80102b88:	85 c0                	test   %eax,%eax
80102b8a:	75 0a                	jne    80102b96 <kbdgetc+0x2c>
    return -1;
80102b8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b91:	e9 23 01 00 00       	jmp    80102cb9 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102b96:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b9d:	e8 9e ff ff ff       	call   80102b40 <inb>
80102ba2:	0f b6 c0             	movzbl %al,%eax
80102ba5:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102ba8:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102baf:	75 17                	jne    80102bc8 <kbdgetc+0x5e>
    shift |= E0ESC;
80102bb1:	a1 9c d6 10 80       	mov    0x8010d69c,%eax
80102bb6:	83 c8 40             	or     $0x40,%eax
80102bb9:	a3 9c d6 10 80       	mov    %eax,0x8010d69c
    return 0;
80102bbe:	b8 00 00 00 00       	mov    $0x0,%eax
80102bc3:	e9 f1 00 00 00       	jmp    80102cb9 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102bc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bcb:	25 80 00 00 00       	and    $0x80,%eax
80102bd0:	85 c0                	test   %eax,%eax
80102bd2:	74 45                	je     80102c19 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bd4:	a1 9c d6 10 80       	mov    0x8010d69c,%eax
80102bd9:	83 e0 40             	and    $0x40,%eax
80102bdc:	85 c0                	test   %eax,%eax
80102bde:	75 08                	jne    80102be8 <kbdgetc+0x7e>
80102be0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102be3:	83 e0 7f             	and    $0x7f,%eax
80102be6:	eb 03                	jmp    80102beb <kbdgetc+0x81>
80102be8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102beb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102bee:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bf1:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102bf6:	0f b6 00             	movzbl (%eax),%eax
80102bf9:	83 c8 40             	or     $0x40,%eax
80102bfc:	0f b6 c0             	movzbl %al,%eax
80102bff:	f7 d0                	not    %eax
80102c01:	89 c2                	mov    %eax,%edx
80102c03:	a1 9c d6 10 80       	mov    0x8010d69c,%eax
80102c08:	21 d0                	and    %edx,%eax
80102c0a:	a3 9c d6 10 80       	mov    %eax,0x8010d69c
    return 0;
80102c0f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c14:	e9 a0 00 00 00       	jmp    80102cb9 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102c19:	a1 9c d6 10 80       	mov    0x8010d69c,%eax
80102c1e:	83 e0 40             	and    $0x40,%eax
80102c21:	85 c0                	test   %eax,%eax
80102c23:	74 14                	je     80102c39 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c25:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c2c:	a1 9c d6 10 80       	mov    0x8010d69c,%eax
80102c31:	83 e0 bf             	and    $0xffffffbf,%eax
80102c34:	a3 9c d6 10 80       	mov    %eax,0x8010d69c
  }

  shift |= shiftcode[data];
80102c39:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c3c:	05 20 b0 10 80       	add    $0x8010b020,%eax
80102c41:	0f b6 00             	movzbl (%eax),%eax
80102c44:	0f b6 d0             	movzbl %al,%edx
80102c47:	a1 9c d6 10 80       	mov    0x8010d69c,%eax
80102c4c:	09 d0                	or     %edx,%eax
80102c4e:	a3 9c d6 10 80       	mov    %eax,0x8010d69c
  shift ^= togglecode[data];
80102c53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c56:	05 20 b1 10 80       	add    $0x8010b120,%eax
80102c5b:	0f b6 00             	movzbl (%eax),%eax
80102c5e:	0f b6 d0             	movzbl %al,%edx
80102c61:	a1 9c d6 10 80       	mov    0x8010d69c,%eax
80102c66:	31 d0                	xor    %edx,%eax
80102c68:	a3 9c d6 10 80       	mov    %eax,0x8010d69c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c6d:	a1 9c d6 10 80       	mov    0x8010d69c,%eax
80102c72:	83 e0 03             	and    $0x3,%eax
80102c75:	8b 04 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%eax
80102c7c:	03 45 fc             	add    -0x4(%ebp),%eax
80102c7f:	0f b6 00             	movzbl (%eax),%eax
80102c82:	0f b6 c0             	movzbl %al,%eax
80102c85:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c88:	a1 9c d6 10 80       	mov    0x8010d69c,%eax
80102c8d:	83 e0 08             	and    $0x8,%eax
80102c90:	85 c0                	test   %eax,%eax
80102c92:	74 22                	je     80102cb6 <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102c94:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c98:	76 0c                	jbe    80102ca6 <kbdgetc+0x13c>
80102c9a:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102c9e:	77 06                	ja     80102ca6 <kbdgetc+0x13c>
      c += 'A' - 'a';
80102ca0:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ca4:	eb 10                	jmp    80102cb6 <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102ca6:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102caa:	76 0a                	jbe    80102cb6 <kbdgetc+0x14c>
80102cac:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102cb0:	77 04                	ja     80102cb6 <kbdgetc+0x14c>
      c += 'a' - 'A';
80102cb2:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102cb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102cb9:	c9                   	leave  
80102cba:	c3                   	ret    

80102cbb <kbdintr>:

void
kbdintr(void)
{
80102cbb:	55                   	push   %ebp
80102cbc:	89 e5                	mov    %esp,%ebp
80102cbe:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102cc1:	c7 04 24 6a 2b 10 80 	movl   $0x80102b6a,(%esp)
80102cc8:	e8 e0 da ff ff       	call   801007ad <consoleintr>
}
80102ccd:	c9                   	leave  
80102cce:	c3                   	ret    
	...

80102cd0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102cd0:	55                   	push   %ebp
80102cd1:	89 e5                	mov    %esp,%ebp
80102cd3:	83 ec 08             	sub    $0x8,%esp
80102cd6:	8b 55 08             	mov    0x8(%ebp),%edx
80102cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cdc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102ce0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ce3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ce7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ceb:	ee                   	out    %al,(%dx)
}
80102cec:	c9                   	leave  
80102ced:	c3                   	ret    

80102cee <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102cee:	55                   	push   %ebp
80102cef:	89 e5                	mov    %esp,%ebp
80102cf1:	53                   	push   %ebx
80102cf2:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102cf5:	9c                   	pushf  
80102cf6:	5b                   	pop    %ebx
80102cf7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102cfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102cfd:	83 c4 10             	add    $0x10,%esp
80102d00:	5b                   	pop    %ebx
80102d01:	5d                   	pop    %ebp
80102d02:	c3                   	ret    

80102d03 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d03:	55                   	push   %ebp
80102d04:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d06:	a1 dc 18 11 80       	mov    0x801118dc,%eax
80102d0b:	8b 55 08             	mov    0x8(%ebp),%edx
80102d0e:	c1 e2 02             	shl    $0x2,%edx
80102d11:	01 c2                	add    %eax,%edx
80102d13:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d16:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d18:	a1 dc 18 11 80       	mov    0x801118dc,%eax
80102d1d:	83 c0 20             	add    $0x20,%eax
80102d20:	8b 00                	mov    (%eax),%eax
}
80102d22:	5d                   	pop    %ebp
80102d23:	c3                   	ret    

80102d24 <lapicinit>:
//PAGEBREAK!

void
lapicinit(int c)
{
80102d24:	55                   	push   %ebp
80102d25:	89 e5                	mov    %esp,%ebp
80102d27:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d2a:	a1 dc 18 11 80       	mov    0x801118dc,%eax
80102d2f:	85 c0                	test   %eax,%eax
80102d31:	0f 84 47 01 00 00    	je     80102e7e <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d37:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d3e:	00 
80102d3f:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d46:	e8 b8 ff ff ff       	call   80102d03 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d4b:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d52:	00 
80102d53:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d5a:	e8 a4 ff ff ff       	call   80102d03 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d5f:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d66:	00 
80102d67:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d6e:	e8 90 ff ff ff       	call   80102d03 <lapicw>
  lapicw(TICR, 10000000); 
80102d73:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d7a:	00 
80102d7b:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d82:	e8 7c ff ff ff       	call   80102d03 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d87:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d8e:	00 
80102d8f:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d96:	e8 68 ff ff ff       	call   80102d03 <lapicw>
  lapicw(LINT1, MASKED);
80102d9b:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102da2:	00 
80102da3:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102daa:	e8 54 ff ff ff       	call   80102d03 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102daf:	a1 dc 18 11 80       	mov    0x801118dc,%eax
80102db4:	83 c0 30             	add    $0x30,%eax
80102db7:	8b 00                	mov    (%eax),%eax
80102db9:	c1 e8 10             	shr    $0x10,%eax
80102dbc:	25 ff 00 00 00       	and    $0xff,%eax
80102dc1:	83 f8 03             	cmp    $0x3,%eax
80102dc4:	76 14                	jbe    80102dda <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102dc6:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dcd:	00 
80102dce:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102dd5:	e8 29 ff ff ff       	call   80102d03 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102dda:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102de1:	00 
80102de2:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102de9:	e8 15 ff ff ff       	call   80102d03 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102dee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102df5:	00 
80102df6:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102dfd:	e8 01 ff ff ff       	call   80102d03 <lapicw>
  lapicw(ESR, 0);
80102e02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e09:	00 
80102e0a:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e11:	e8 ed fe ff ff       	call   80102d03 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e1d:	00 
80102e1e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e25:	e8 d9 fe ff ff       	call   80102d03 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e31:	00 
80102e32:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e39:	e8 c5 fe ff ff       	call   80102d03 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e3e:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e45:	00 
80102e46:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e4d:	e8 b1 fe ff ff       	call   80102d03 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e52:	90                   	nop
80102e53:	a1 dc 18 11 80       	mov    0x801118dc,%eax
80102e58:	05 00 03 00 00       	add    $0x300,%eax
80102e5d:	8b 00                	mov    (%eax),%eax
80102e5f:	25 00 10 00 00       	and    $0x1000,%eax
80102e64:	85 c0                	test   %eax,%eax
80102e66:	75 eb                	jne    80102e53 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e6f:	00 
80102e70:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e77:	e8 87 fe ff ff       	call   80102d03 <lapicw>
80102e7c:	eb 01                	jmp    80102e7f <lapicinit+0x15b>

void
lapicinit(int c)
{
  if(!lapic) 
    return;
80102e7e:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102e7f:	c9                   	leave  
80102e80:	c3                   	ret    

80102e81 <cpunum>:

int
cpunum(void)
{
80102e81:	55                   	push   %ebp
80102e82:	89 e5                	mov    %esp,%ebp
80102e84:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e87:	e8 62 fe ff ff       	call   80102cee <readeflags>
80102e8c:	25 00 02 00 00       	and    $0x200,%eax
80102e91:	85 c0                	test   %eax,%eax
80102e93:	74 29                	je     80102ebe <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80102e95:	a1 a0 d6 10 80       	mov    0x8010d6a0,%eax
80102e9a:	85 c0                	test   %eax,%eax
80102e9c:	0f 94 c2             	sete   %dl
80102e9f:	83 c0 01             	add    $0x1,%eax
80102ea2:	a3 a0 d6 10 80       	mov    %eax,0x8010d6a0
80102ea7:	84 d2                	test   %dl,%dl
80102ea9:	74 13                	je     80102ebe <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eab:	8b 45 04             	mov    0x4(%ebp),%eax
80102eae:	89 44 24 04          	mov    %eax,0x4(%esp)
80102eb2:	c7 04 24 9c 99 10 80 	movl   $0x8010999c,(%esp)
80102eb9:	e8 e3 d4 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102ebe:	a1 dc 18 11 80       	mov    0x801118dc,%eax
80102ec3:	85 c0                	test   %eax,%eax
80102ec5:	74 0f                	je     80102ed6 <cpunum+0x55>
    return lapic[ID]>>24;
80102ec7:	a1 dc 18 11 80       	mov    0x801118dc,%eax
80102ecc:	83 c0 20             	add    $0x20,%eax
80102ecf:	8b 00                	mov    (%eax),%eax
80102ed1:	c1 e8 18             	shr    $0x18,%eax
80102ed4:	eb 05                	jmp    80102edb <cpunum+0x5a>
  return 0;
80102ed6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102edb:	c9                   	leave  
80102edc:	c3                   	ret    

80102edd <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102edd:	55                   	push   %ebp
80102ede:	89 e5                	mov    %esp,%ebp
80102ee0:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ee3:	a1 dc 18 11 80       	mov    0x801118dc,%eax
80102ee8:	85 c0                	test   %eax,%eax
80102eea:	74 14                	je     80102f00 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102eec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ef3:	00 
80102ef4:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102efb:	e8 03 fe ff ff       	call   80102d03 <lapicw>
}
80102f00:	c9                   	leave  
80102f01:	c3                   	ret    

80102f02 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f02:	55                   	push   %ebp
80102f03:	89 e5                	mov    %esp,%ebp
}
80102f05:	5d                   	pop    %ebp
80102f06:	c3                   	ret    

80102f07 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f07:	55                   	push   %ebp
80102f08:	89 e5                	mov    %esp,%ebp
80102f0a:	83 ec 1c             	sub    $0x1c,%esp
80102f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80102f10:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80102f13:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f1a:	00 
80102f1b:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f22:	e8 a9 fd ff ff       	call   80102cd0 <outb>
  outb(IO_RTC+1, 0x0A);
80102f27:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f2e:	00 
80102f2f:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f36:	e8 95 fd ff ff       	call   80102cd0 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f3b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f42:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f45:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f4a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f4d:	8d 50 02             	lea    0x2(%eax),%edx
80102f50:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f53:	c1 e8 04             	shr    $0x4,%eax
80102f56:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f59:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f5d:	c1 e0 18             	shl    $0x18,%eax
80102f60:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f64:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f6b:	e8 93 fd ff ff       	call   80102d03 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f70:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f77:	00 
80102f78:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f7f:	e8 7f fd ff ff       	call   80102d03 <lapicw>
  microdelay(200);
80102f84:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f8b:	e8 72 ff ff ff       	call   80102f02 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f90:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f97:	00 
80102f98:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f9f:	e8 5f fd ff ff       	call   80102d03 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102fa4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fab:	e8 52 ff ff ff       	call   80102f02 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102fb0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102fb7:	eb 40                	jmp    80102ff9 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102fb9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fbd:	c1 e0 18             	shl    $0x18,%eax
80102fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fc4:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fcb:	e8 33 fd ff ff       	call   80102d03 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fd3:	c1 e8 0c             	shr    $0xc,%eax
80102fd6:	80 cc 06             	or     $0x6,%ah
80102fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fdd:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fe4:	e8 1a fd ff ff       	call   80102d03 <lapicw>
    microdelay(200);
80102fe9:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ff0:	e8 0d ff ff ff       	call   80102f02 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ff5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102ff9:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102ffd:	7e ba                	jle    80102fb9 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102fff:	c9                   	leave  
80103000:	c3                   	ret    
80103001:	00 00                	add    %al,(%eax)
	...

80103004 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80103004:	55                   	push   %ebp
80103005:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80103007:	fa                   	cli    
}
80103008:	5d                   	pop    %ebp
80103009:	c3                   	ret    

8010300a <sti>:

static inline void
sti(void)
{
8010300a:	55                   	push   %ebp
8010300b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010300d:	fb                   	sti    
}
8010300e:	5d                   	pop    %ebp
8010300f:	c3                   	ret    

80103010 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103010:	55                   	push   %ebp
80103011:	89 e5                	mov    %esp,%ebp
80103013:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103016:	c7 44 24 04 c8 99 10 	movl   $0x801099c8,0x4(%esp)
8010301d:	80 
8010301e:	c7 04 24 e0 18 11 80 	movl   $0x801118e0,(%esp)
80103025:	e8 b8 2f 00 00       	call   80105fe2 <initlock>
  readsb(ROOTDEV, &sb);
8010302a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010302d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103031:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103038:	e8 af e2 ff ff       	call   801012ec <readsb>
  log.start = sb.size - sb.nlog;
8010303d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103040:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103043:	89 d1                	mov    %edx,%ecx
80103045:	29 c1                	sub    %eax,%ecx
80103047:	89 c8                	mov    %ecx,%eax
80103049:	a3 14 19 11 80       	mov    %eax,0x80111914
  log.size = sb.nlog;
8010304e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103051:	a3 18 19 11 80       	mov    %eax,0x80111918
  log.dev = ROOTDEV;
80103056:	c7 05 20 19 11 80 01 	movl   $0x1,0x80111920
8010305d:	00 00 00 
  recover_from_log();
80103060:	e8 97 01 00 00       	call   801031fc <recover_from_log>
}
80103065:	c9                   	leave  
80103066:	c3                   	ret    

80103067 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103067:	55                   	push   %ebp
80103068:	89 e5                	mov    %esp,%ebp
8010306a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010306d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103074:	e9 89 00 00 00       	jmp    80103102 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103079:	a1 14 19 11 80       	mov    0x80111914,%eax
8010307e:	03 45 f4             	add    -0xc(%ebp),%eax
80103081:	83 c0 01             	add    $0x1,%eax
80103084:	89 c2                	mov    %eax,%edx
80103086:	a1 20 19 11 80       	mov    0x80111920,%eax
8010308b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010308f:	89 04 24             	mov    %eax,(%esp)
80103092:	e8 0f d1 ff ff       	call   801001a6 <bread>
80103097:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010309a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010309d:	83 c0 10             	add    $0x10,%eax
801030a0:	8b 04 85 e8 18 11 80 	mov    -0x7feee718(,%eax,4),%eax
801030a7:	89 c2                	mov    %eax,%edx
801030a9:	a1 20 19 11 80       	mov    0x80111920,%eax
801030ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801030b2:	89 04 24             	mov    %eax,(%esp)
801030b5:	e8 ec d0 ff ff       	call   801001a6 <bread>
801030ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801030bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030c0:	8d 50 18             	lea    0x18(%eax),%edx
801030c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030c6:	83 c0 18             	add    $0x18,%eax
801030c9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801030d0:	00 
801030d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801030d5:	89 04 24             	mov    %eax,(%esp)
801030d8:	e8 5c 32 00 00       	call   80106339 <memmove>
    bwrite(dbuf);  // write dst to disk
801030dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030e0:	89 04 24             	mov    %eax,(%esp)
801030e3:	e8 f5 d0 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
801030e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030eb:	89 04 24             	mov    %eax,(%esp)
801030ee:	e8 24 d1 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
801030f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030f6:	89 04 24             	mov    %eax,(%esp)
801030f9:	e8 19 d1 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801030fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103102:	a1 24 19 11 80       	mov    0x80111924,%eax
80103107:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010310a:	0f 8f 69 ff ff ff    	jg     80103079 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103110:	c9                   	leave  
80103111:	c3                   	ret    

80103112 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103112:	55                   	push   %ebp
80103113:	89 e5                	mov    %esp,%ebp
80103115:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103118:	a1 14 19 11 80       	mov    0x80111914,%eax
8010311d:	89 c2                	mov    %eax,%edx
8010311f:	a1 20 19 11 80       	mov    0x80111920,%eax
80103124:	89 54 24 04          	mov    %edx,0x4(%esp)
80103128:	89 04 24             	mov    %eax,(%esp)
8010312b:	e8 76 d0 ff ff       	call   801001a6 <bread>
80103130:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103133:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103136:	83 c0 18             	add    $0x18,%eax
80103139:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010313c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010313f:	8b 00                	mov    (%eax),%eax
80103141:	a3 24 19 11 80       	mov    %eax,0x80111924
  for (i = 0; i < log.lh.n; i++) {
80103146:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010314d:	eb 1b                	jmp    8010316a <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
8010314f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103152:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103155:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103159:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010315c:	83 c2 10             	add    $0x10,%edx
8010315f:	89 04 95 e8 18 11 80 	mov    %eax,-0x7feee718(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103166:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010316a:	a1 24 19 11 80       	mov    0x80111924,%eax
8010316f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103172:	7f db                	jg     8010314f <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103174:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103177:	89 04 24             	mov    %eax,(%esp)
8010317a:	e8 98 d0 ff ff       	call   80100217 <brelse>
}
8010317f:	c9                   	leave  
80103180:	c3                   	ret    

80103181 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103181:	55                   	push   %ebp
80103182:	89 e5                	mov    %esp,%ebp
80103184:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103187:	a1 14 19 11 80       	mov    0x80111914,%eax
8010318c:	89 c2                	mov    %eax,%edx
8010318e:	a1 20 19 11 80       	mov    0x80111920,%eax
80103193:	89 54 24 04          	mov    %edx,0x4(%esp)
80103197:	89 04 24             	mov    %eax,(%esp)
8010319a:	e8 07 d0 ff ff       	call   801001a6 <bread>
8010319f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801031a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031a5:	83 c0 18             	add    $0x18,%eax
801031a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801031ab:	8b 15 24 19 11 80    	mov    0x80111924,%edx
801031b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031b4:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801031b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801031bd:	eb 1b                	jmp    801031da <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801031bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c2:	83 c0 10             	add    $0x10,%eax
801031c5:	8b 0c 85 e8 18 11 80 	mov    -0x7feee718(,%eax,4),%ecx
801031cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801031d2:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801031d6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801031da:	a1 24 19 11 80       	mov    0x80111924,%eax
801031df:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801031e2:	7f db                	jg     801031bf <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
801031e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031e7:	89 04 24             	mov    %eax,(%esp)
801031ea:	e8 ee cf ff ff       	call   801001dd <bwrite>
  brelse(buf);
801031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f2:	89 04 24             	mov    %eax,(%esp)
801031f5:	e8 1d d0 ff ff       	call   80100217 <brelse>
}
801031fa:	c9                   	leave  
801031fb:	c3                   	ret    

801031fc <recover_from_log>:

static void
recover_from_log(void)
{
801031fc:	55                   	push   %ebp
801031fd:	89 e5                	mov    %esp,%ebp
801031ff:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103202:	e8 0b ff ff ff       	call   80103112 <read_head>
  install_trans(); // if committed, copy from log to disk
80103207:	e8 5b fe ff ff       	call   80103067 <install_trans>
  log.lh.n = 0;
8010320c:	c7 05 24 19 11 80 00 	movl   $0x0,0x80111924
80103213:	00 00 00 
  write_head(); // clear the log
80103216:	e8 66 ff ff ff       	call   80103181 <write_head>
}
8010321b:	c9                   	leave  
8010321c:	c3                   	ret    

8010321d <begin_trans>:

void
begin_trans(void)
{
8010321d:	55                   	push   %ebp
8010321e:	89 e5                	mov    %esp,%ebp
  //acquire(&log.lock);
  sti();
80103220:	e8 e5 fd ff ff       	call   8010300a <sti>
  while (log.busy) {
80103225:	90                   	nop
80103226:	a1 1c 19 11 80       	mov    0x8011191c,%eax
8010322b:	85 c0                	test   %eax,%eax
8010322d:	75 f7                	jne    80103226 <begin_trans+0x9>
    //cprintf("begin_trans - sleep\n");
    //sleep(&log, &log.lock);
  }
  cli();
8010322f:	e8 d0 fd ff ff       	call   80103004 <cli>
  log.busy = 1;
80103234:	c7 05 1c 19 11 80 01 	movl   $0x1,0x8011191c
8010323b:	00 00 00 
  //release(&log.lock);
}
8010323e:	5d                   	pop    %ebp
8010323f:	c3                   	ret    

80103240 <commit_trans>:

void
commit_trans(void)
{
80103240:	55                   	push   %ebp
80103241:	89 e5                	mov    %esp,%ebp
80103243:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103246:	a1 24 19 11 80       	mov    0x80111924,%eax
8010324b:	85 c0                	test   %eax,%eax
8010324d:	7e 19                	jle    80103268 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
8010324f:	e8 2d ff ff ff       	call   80103181 <write_head>
    install_trans(); // Now install writes to home locations
80103254:	e8 0e fe ff ff       	call   80103067 <install_trans>
    log.lh.n = 0; 
80103259:	c7 05 24 19 11 80 00 	movl   $0x0,0x80111924
80103260:	00 00 00 
    write_head();    // Erase the transaction from the log
80103263:	e8 19 ff ff ff       	call   80103181 <write_head>
  }
  
  acquire(&log.lock);
80103268:	c7 04 24 e0 18 11 80 	movl   $0x801118e0,(%esp)
8010326f:	e8 8f 2d 00 00       	call   80106003 <acquire>
  log.busy = 0;
80103274:	c7 05 1c 19 11 80 00 	movl   $0x0,0x8011191c
8010327b:	00 00 00 
  //wakeup(&log);
  release(&log.lock);
8010327e:	c7 04 24 e0 18 11 80 	movl   $0x801118e0,(%esp)
80103285:	e8 f1 2d 00 00       	call   8010607b <release>
}
8010328a:	c9                   	leave  
8010328b:	c3                   	ret    

8010328c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010328c:	55                   	push   %ebp
8010328d:	89 e5                	mov    %esp,%ebp
8010328f:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103292:	a1 24 19 11 80       	mov    0x80111924,%eax
80103297:	83 f8 09             	cmp    $0x9,%eax
8010329a:	7f 12                	jg     801032ae <log_write+0x22>
8010329c:	a1 24 19 11 80       	mov    0x80111924,%eax
801032a1:	8b 15 18 19 11 80    	mov    0x80111918,%edx
801032a7:	83 ea 01             	sub    $0x1,%edx
801032aa:	39 d0                	cmp    %edx,%eax
801032ac:	7c 0c                	jl     801032ba <log_write+0x2e>
    panic("too big a transaction");
801032ae:	c7 04 24 cc 99 10 80 	movl   $0x801099cc,(%esp)
801032b5:	e8 83 d2 ff ff       	call   8010053d <panic>
  if (!log.busy)
801032ba:	a1 1c 19 11 80       	mov    0x8011191c,%eax
801032bf:	85 c0                	test   %eax,%eax
801032c1:	75 0c                	jne    801032cf <log_write+0x43>
    panic("write outside of trans");
801032c3:	c7 04 24 e2 99 10 80 	movl   $0x801099e2,(%esp)
801032ca:	e8 6e d2 ff ff       	call   8010053d <panic>

  for (i = 0; i < log.lh.n; i++) {
801032cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d6:	eb 1d                	jmp    801032f5 <log_write+0x69>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
801032d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032db:	83 c0 10             	add    $0x10,%eax
801032de:	8b 04 85 e8 18 11 80 	mov    -0x7feee718(,%eax,4),%eax
801032e5:	89 c2                	mov    %eax,%edx
801032e7:	8b 45 08             	mov    0x8(%ebp),%eax
801032ea:	8b 40 08             	mov    0x8(%eax),%eax
801032ed:	39 c2                	cmp    %eax,%edx
801032ef:	74 10                	je     80103301 <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
801032f1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f5:	a1 24 19 11 80       	mov    0x80111924,%eax
801032fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801032fd:	7f d9                	jg     801032d8 <log_write+0x4c>
801032ff:	eb 01                	jmp    80103302 <log_write+0x76>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
80103301:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103302:	8b 45 08             	mov    0x8(%ebp),%eax
80103305:	8b 40 08             	mov    0x8(%eax),%eax
80103308:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010330b:	83 c2 10             	add    $0x10,%edx
8010330e:	89 04 95 e8 18 11 80 	mov    %eax,-0x7feee718(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
80103315:	a1 14 19 11 80       	mov    0x80111914,%eax
8010331a:	03 45 f4             	add    -0xc(%ebp),%eax
8010331d:	83 c0 01             	add    $0x1,%eax
80103320:	89 c2                	mov    %eax,%edx
80103322:	8b 45 08             	mov    0x8(%ebp),%eax
80103325:	8b 40 04             	mov    0x4(%eax),%eax
80103328:	89 54 24 04          	mov    %edx,0x4(%esp)
8010332c:	89 04 24             	mov    %eax,(%esp)
8010332f:	e8 72 ce ff ff       	call   801001a6 <bread>
80103334:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103337:	8b 45 08             	mov    0x8(%ebp),%eax
8010333a:	8d 50 18             	lea    0x18(%eax),%edx
8010333d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103340:	83 c0 18             	add    $0x18,%eax
80103343:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010334a:	00 
8010334b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010334f:	89 04 24             	mov    %eax,(%esp)
80103352:	e8 e2 2f 00 00       	call   80106339 <memmove>
  bwrite(lbuf);
80103357:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010335a:	89 04 24             	mov    %eax,(%esp)
8010335d:	e8 7b ce ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
80103362:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103365:	89 04 24             	mov    %eax,(%esp)
80103368:	e8 aa ce ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
8010336d:	a1 24 19 11 80       	mov    0x80111924,%eax
80103372:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103375:	75 0d                	jne    80103384 <log_write+0xf8>
    log.lh.n++;
80103377:	a1 24 19 11 80       	mov    0x80111924,%eax
8010337c:	83 c0 01             	add    $0x1,%eax
8010337f:	a3 24 19 11 80       	mov    %eax,0x80111924
  b->flags |= B_DIRTY; // XXX prevent eviction
80103384:	8b 45 08             	mov    0x8(%ebp),%eax
80103387:	8b 00                	mov    (%eax),%eax
80103389:	89 c2                	mov    %eax,%edx
8010338b:	83 ca 04             	or     $0x4,%edx
8010338e:	8b 45 08             	mov    0x8(%ebp),%eax
80103391:	89 10                	mov    %edx,(%eax)
}
80103393:	c9                   	leave  
80103394:	c3                   	ret    
80103395:	00 00                	add    %al,(%eax)
	...

80103398 <v2p>:
80103398:	55                   	push   %ebp
80103399:	89 e5                	mov    %esp,%ebp
8010339b:	8b 45 08             	mov    0x8(%ebp),%eax
8010339e:	05 00 00 00 80       	add    $0x80000000,%eax
801033a3:	5d                   	pop    %ebp
801033a4:	c3                   	ret    

801033a5 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801033a5:	55                   	push   %ebp
801033a6:	89 e5                	mov    %esp,%ebp
801033a8:	8b 45 08             	mov    0x8(%ebp),%eax
801033ab:	05 00 00 00 80       	add    $0x80000000,%eax
801033b0:	5d                   	pop    %ebp
801033b1:	c3                   	ret    

801033b2 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801033b2:	55                   	push   %ebp
801033b3:	89 e5                	mov    %esp,%ebp
801033b5:	53                   	push   %ebx
801033b6:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801033b9:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801033bc:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801033bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801033c2:	89 c3                	mov    %eax,%ebx
801033c4:	89 d8                	mov    %ebx,%eax
801033c6:	f0 87 02             	lock xchg %eax,(%edx)
801033c9:	89 c3                	mov    %eax,%ebx
801033cb:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801033ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801033d1:	83 c4 10             	add    $0x10,%esp
801033d4:	5b                   	pop    %ebx
801033d5:	5d                   	pop    %ebp
801033d6:	c3                   	ret    

801033d7 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801033d7:	55                   	push   %ebp
801033d8:	89 e5                	mov    %esp,%ebp
801033da:	83 e4 f0             	and    $0xfffffff0,%esp
801033dd:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801033e0:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801033e7:	80 
801033e8:	c7 04 24 9c 7a 18 80 	movl   $0x80187a9c,(%esp)
801033ef:	e8 d1 f5 ff ff       	call   801029c5 <kinit1>
  kvmalloc();      // kernel page table
801033f4:	e8 39 5c 00 00       	call   80109032 <kvmalloc>
  mpinit();        // collect info about this machine
801033f9:	e8 63 04 00 00       	call   80103861 <mpinit>
  lapicinit(mpbcpu());
801033fe:	e8 2e 02 00 00       	call   80103631 <mpbcpu>
80103403:	89 04 24             	mov    %eax,(%esp)
80103406:	e8 19 f9 ff ff       	call   80102d24 <lapicinit>
  seginit();       // set up segments
8010340b:	e8 c5 55 00 00       	call   801089d5 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103410:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103416:	0f b6 00             	movzbl (%eax),%eax
80103419:	0f b6 c0             	movzbl %al,%eax
8010341c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103420:	c7 04 24 f9 99 10 80 	movl   $0x801099f9,(%esp)
80103427:	e8 75 cf ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
8010342c:	e8 95 06 00 00       	call   80103ac6 <picinit>
  ioapicinit();    // another interrupt controller
80103431:	e8 7f f4 ff ff       	call   801028b5 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103436:	e8 52 d6 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
8010343b:	e8 e0 48 00 00       	call   80107d20 <uartinit>
  pinit();         // process table
80103440:	e8 b0 0b 00 00       	call   80103ff5 <pinit>
  tvinit();        // trap vectors
80103445:	e8 79 44 00 00       	call   801078c3 <tvinit>
  binit();         // buffer cache
8010344a:	e8 e5 cb ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010344f:	e8 ac da ff ff       	call   80100f00 <fileinit>
  iinit();         // inode cache
80103454:	e8 5a e1 ff ff       	call   801015b3 <iinit>
  ideinit();       // disk
80103459:	e8 d4 f0 ff ff       	call   80102532 <ideinit>
  if(!ismp)
8010345e:	a1 64 19 11 80       	mov    0x80111964,%eax
80103463:	85 c0                	test   %eax,%eax
80103465:	75 05                	jne    8010346c <main+0x95>
    timerinit();   // uniprocessor timer
80103467:	e8 9a 43 00 00       	call   80107806 <timerinit>
  startothers();   // start other processors
8010346c:	e8 87 00 00 00       	call   801034f8 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103471:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103478:	8e 
80103479:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103480:	e8 78 f5 ff ff       	call   801029fd <kinit2>
  userinit();      // first user process
80103485:	e8 89 0c 00 00       	call   80104113 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010348a:	e8 22 00 00 00       	call   801034b1 <mpmain>

8010348f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010348f:	55                   	push   %ebp
80103490:	89 e5                	mov    %esp,%ebp
80103492:	83 ec 18             	sub    $0x18,%esp
  switchkvm(); 
80103495:	e8 af 5b 00 00       	call   80109049 <switchkvm>
  seginit();
8010349a:	e8 36 55 00 00       	call   801089d5 <seginit>
  lapicinit(cpunum());
8010349f:	e8 dd f9 ff ff       	call   80102e81 <cpunum>
801034a4:	89 04 24             	mov    %eax,(%esp)
801034a7:	e8 78 f8 ff ff       	call   80102d24 <lapicinit>
  mpmain();
801034ac:	e8 00 00 00 00       	call   801034b1 <mpmain>

801034b1 <mpmain>:
// }

// Common CPU setup code.
static void
mpmain(void)
{
801034b1:	55                   	push   %ebp
801034b2:	89 e5                	mov    %esp,%ebp
801034b4:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801034b7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801034bd:	0f b6 00             	movzbl (%eax),%eax
801034c0:	0f b6 c0             	movzbl %al,%eax
801034c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801034c7:	c7 04 24 10 9a 10 80 	movl   $0x80109a10,(%esp)
801034ce:	e8 ce ce ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
801034d3:	e8 5f 45 00 00       	call   80107a37 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801034d8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801034de:	05 a8 00 00 00       	add    $0xa8,%eax
801034e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801034ea:	00 
801034eb:	89 04 24             	mov    %eax,(%esp)
801034ee:	e8 bf fe ff ff       	call   801033b2 <xchg>
//   createInternalProcess("inSwapper",(void*)inSwapper);
  scheduler();     // start running processes
801034f3:	e8 84 12 00 00       	call   8010477c <scheduler>

801034f8 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801034f8:	55                   	push   %ebp
801034f9:	89 e5                	mov    %esp,%ebp
801034fb:	53                   	push   %ebx
801034fc:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801034ff:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103506:	e8 9a fe ff ff       	call   801033a5 <p2v>
8010350b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010350e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103513:	89 44 24 08          	mov    %eax,0x8(%esp)
80103517:	c7 44 24 04 6c d5 10 	movl   $0x8010d56c,0x4(%esp)
8010351e:	80 
8010351f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103522:	89 04 24             	mov    %eax,(%esp)
80103525:	e8 0f 2e 00 00       	call   80106339 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010352a:	c7 45 f4 80 19 11 80 	movl   $0x80111980,-0xc(%ebp)
80103531:	e9 86 00 00 00       	jmp    801035bc <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
80103536:	e8 46 f9 ff ff       	call   80102e81 <cpunum>
8010353b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103541:	05 80 19 11 80       	add    $0x80111980,%eax
80103546:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103549:	74 69                	je     801035b4 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010354b:	e8 a3 f5 ff ff       	call   80102af3 <kalloc>
80103550:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103553:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103556:	83 e8 04             	sub    $0x4,%eax
80103559:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010355c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103562:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103564:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103567:	83 e8 08             	sub    $0x8,%eax
8010356a:	c7 00 8f 34 10 80    	movl   $0x8010348f,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103573:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103576:	c7 04 24 00 c0 10 80 	movl   $0x8010c000,(%esp)
8010357d:	e8 16 fe ff ff       	call   80103398 <v2p>
80103582:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103587:	89 04 24             	mov    %eax,(%esp)
8010358a:	e8 09 fe ff ff       	call   80103398 <v2p>
8010358f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103592:	0f b6 12             	movzbl (%edx),%edx
80103595:	0f b6 d2             	movzbl %dl,%edx
80103598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010359c:	89 14 24             	mov    %edx,(%esp)
8010359f:	e8 63 f9 ff ff       	call   80102f07 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801035a4:	90                   	nop
801035a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035a8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801035ae:	85 c0                	test   %eax,%eax
801035b0:	74 f3                	je     801035a5 <startothers+0xad>
801035b2:	eb 01                	jmp    801035b5 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801035b4:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801035b5:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801035bc:	a1 60 1f 11 80       	mov    0x80111f60,%eax
801035c1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801035c7:	05 80 19 11 80       	add    $0x80111980,%eax
801035cc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035cf:	0f 87 61 ff ff ff    	ja     80103536 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801035d5:	83 c4 24             	add    $0x24,%esp
801035d8:	5b                   	pop    %ebx
801035d9:	5d                   	pop    %ebp
801035da:	c3                   	ret    
	...

801035dc <p2v>:
801035dc:	55                   	push   %ebp
801035dd:	89 e5                	mov    %esp,%ebp
801035df:	8b 45 08             	mov    0x8(%ebp),%eax
801035e2:	05 00 00 00 80       	add    $0x80000000,%eax
801035e7:	5d                   	pop    %ebp
801035e8:	c3                   	ret    

801035e9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801035e9:	55                   	push   %ebp
801035ea:	89 e5                	mov    %esp,%ebp
801035ec:	53                   	push   %ebx
801035ed:	83 ec 14             	sub    $0x14,%esp
801035f0:	8b 45 08             	mov    0x8(%ebp),%eax
801035f3:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801035f7:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801035fb:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801035ff:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80103603:	ec                   	in     (%dx),%al
80103604:	89 c3                	mov    %eax,%ebx
80103606:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103609:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
8010360d:	83 c4 14             	add    $0x14,%esp
80103610:	5b                   	pop    %ebx
80103611:	5d                   	pop    %ebp
80103612:	c3                   	ret    

80103613 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103613:	55                   	push   %ebp
80103614:	89 e5                	mov    %esp,%ebp
80103616:	83 ec 08             	sub    $0x8,%esp
80103619:	8b 55 08             	mov    0x8(%ebp),%edx
8010361c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010361f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103623:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103626:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010362a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010362e:	ee                   	out    %al,(%dx)
}
8010362f:	c9                   	leave  
80103630:	c3                   	ret    

80103631 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103631:	55                   	push   %ebp
80103632:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103634:	a1 a4 d6 10 80       	mov    0x8010d6a4,%eax
80103639:	89 c2                	mov    %eax,%edx
8010363b:	b8 80 19 11 80       	mov    $0x80111980,%eax
80103640:	89 d1                	mov    %edx,%ecx
80103642:	29 c1                	sub    %eax,%ecx
80103644:	89 c8                	mov    %ecx,%eax
80103646:	c1 f8 02             	sar    $0x2,%eax
80103649:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010364f:	5d                   	pop    %ebp
80103650:	c3                   	ret    

80103651 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103651:	55                   	push   %ebp
80103652:	89 e5                	mov    %esp,%ebp
80103654:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103657:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010365e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103665:	eb 13                	jmp    8010367a <sum+0x29>
    sum += addr[i];
80103667:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010366a:	03 45 08             	add    0x8(%ebp),%eax
8010366d:	0f b6 00             	movzbl (%eax),%eax
80103670:	0f b6 c0             	movzbl %al,%eax
80103673:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103676:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010367a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010367d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103680:	7c e5                	jl     80103667 <sum+0x16>
    sum += addr[i];
  return sum;
80103682:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103685:	c9                   	leave  
80103686:	c3                   	ret    

80103687 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103687:	55                   	push   %ebp
80103688:	89 e5                	mov    %esp,%ebp
8010368a:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	89 04 24             	mov    %eax,(%esp)
80103693:	e8 44 ff ff ff       	call   801035dc <p2v>
80103698:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
8010369b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010369e:	03 45 f0             	add    -0x10(%ebp),%eax
801036a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801036a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801036aa:	eb 3f                	jmp    801036eb <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801036ac:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801036b3:	00 
801036b4:	c7 44 24 04 24 9a 10 	movl   $0x80109a24,0x4(%esp)
801036bb:	80 
801036bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036bf:	89 04 24             	mov    %eax,(%esp)
801036c2:	e8 16 2c 00 00       	call   801062dd <memcmp>
801036c7:	85 c0                	test   %eax,%eax
801036c9:	75 1c                	jne    801036e7 <mpsearch1+0x60>
801036cb:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801036d2:	00 
801036d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d6:	89 04 24             	mov    %eax,(%esp)
801036d9:	e8 73 ff ff ff       	call   80103651 <sum>
801036de:	84 c0                	test   %al,%al
801036e0:	75 05                	jne    801036e7 <mpsearch1+0x60>
      return (struct mp*)p;
801036e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e5:	eb 11                	jmp    801036f8 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801036e7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801036eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036ee:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801036f1:	72 b9                	jb     801036ac <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801036f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801036f8:	c9                   	leave  
801036f9:	c3                   	ret    

801036fa <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801036fa:	55                   	push   %ebp
801036fb:	89 e5                	mov    %esp,%ebp
801036fd:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103700:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010370a:	83 c0 0f             	add    $0xf,%eax
8010370d:	0f b6 00             	movzbl (%eax),%eax
80103710:	0f b6 c0             	movzbl %al,%eax
80103713:	89 c2                	mov    %eax,%edx
80103715:	c1 e2 08             	shl    $0x8,%edx
80103718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010371b:	83 c0 0e             	add    $0xe,%eax
8010371e:	0f b6 00             	movzbl (%eax),%eax
80103721:	0f b6 c0             	movzbl %al,%eax
80103724:	09 d0                	or     %edx,%eax
80103726:	c1 e0 04             	shl    $0x4,%eax
80103729:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010372c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103730:	74 21                	je     80103753 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103732:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103739:	00 
8010373a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010373d:	89 04 24             	mov    %eax,(%esp)
80103740:	e8 42 ff ff ff       	call   80103687 <mpsearch1>
80103745:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103748:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010374c:	74 50                	je     8010379e <mpsearch+0xa4>
      return mp;
8010374e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103751:	eb 5f                	jmp    801037b2 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103753:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103756:	83 c0 14             	add    $0x14,%eax
80103759:	0f b6 00             	movzbl (%eax),%eax
8010375c:	0f b6 c0             	movzbl %al,%eax
8010375f:	89 c2                	mov    %eax,%edx
80103761:	c1 e2 08             	shl    $0x8,%edx
80103764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103767:	83 c0 13             	add    $0x13,%eax
8010376a:	0f b6 00             	movzbl (%eax),%eax
8010376d:	0f b6 c0             	movzbl %al,%eax
80103770:	09 d0                	or     %edx,%eax
80103772:	c1 e0 0a             	shl    $0xa,%eax
80103775:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103778:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010377b:	2d 00 04 00 00       	sub    $0x400,%eax
80103780:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103787:	00 
80103788:	89 04 24             	mov    %eax,(%esp)
8010378b:	e8 f7 fe ff ff       	call   80103687 <mpsearch1>
80103790:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103793:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103797:	74 05                	je     8010379e <mpsearch+0xa4>
      return mp;
80103799:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010379c:	eb 14                	jmp    801037b2 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
8010379e:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801037a5:	00 
801037a6:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801037ad:	e8 d5 fe ff ff       	call   80103687 <mpsearch1>
}
801037b2:	c9                   	leave  
801037b3:	c3                   	ret    

801037b4 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801037b4:	55                   	push   %ebp
801037b5:	89 e5                	mov    %esp,%ebp
801037b7:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801037ba:	e8 3b ff ff ff       	call   801036fa <mpsearch>
801037bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801037c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037c6:	74 0a                	je     801037d2 <mpconfig+0x1e>
801037c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037cb:	8b 40 04             	mov    0x4(%eax),%eax
801037ce:	85 c0                	test   %eax,%eax
801037d0:	75 0a                	jne    801037dc <mpconfig+0x28>
    return 0;
801037d2:	b8 00 00 00 00       	mov    $0x0,%eax
801037d7:	e9 83 00 00 00       	jmp    8010385f <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801037dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037df:	8b 40 04             	mov    0x4(%eax),%eax
801037e2:	89 04 24             	mov    %eax,(%esp)
801037e5:	e8 f2 fd ff ff       	call   801035dc <p2v>
801037ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801037ed:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801037f4:	00 
801037f5:	c7 44 24 04 29 9a 10 	movl   $0x80109a29,0x4(%esp)
801037fc:	80 
801037fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103800:	89 04 24             	mov    %eax,(%esp)
80103803:	e8 d5 2a 00 00       	call   801062dd <memcmp>
80103808:	85 c0                	test   %eax,%eax
8010380a:	74 07                	je     80103813 <mpconfig+0x5f>
    return 0;
8010380c:	b8 00 00 00 00       	mov    $0x0,%eax
80103811:	eb 4c                	jmp    8010385f <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103816:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010381a:	3c 01                	cmp    $0x1,%al
8010381c:	74 12                	je     80103830 <mpconfig+0x7c>
8010381e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103821:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103825:	3c 04                	cmp    $0x4,%al
80103827:	74 07                	je     80103830 <mpconfig+0x7c>
    return 0;
80103829:	b8 00 00 00 00       	mov    $0x0,%eax
8010382e:	eb 2f                	jmp    8010385f <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103833:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103837:	0f b7 c0             	movzwl %ax,%eax
8010383a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010383e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103841:	89 04 24             	mov    %eax,(%esp)
80103844:	e8 08 fe ff ff       	call   80103651 <sum>
80103849:	84 c0                	test   %al,%al
8010384b:	74 07                	je     80103854 <mpconfig+0xa0>
    return 0;
8010384d:	b8 00 00 00 00       	mov    $0x0,%eax
80103852:	eb 0b                	jmp    8010385f <mpconfig+0xab>
  *pmp = mp;
80103854:	8b 45 08             	mov    0x8(%ebp),%eax
80103857:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010385a:	89 10                	mov    %edx,(%eax)
  return conf;
8010385c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010385f:	c9                   	leave  
80103860:	c3                   	ret    

80103861 <mpinit>:

void
mpinit(void)
{
80103861:	55                   	push   %ebp
80103862:	89 e5                	mov    %esp,%ebp
80103864:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103867:	c7 05 a4 d6 10 80 80 	movl   $0x80111980,0x8010d6a4
8010386e:	19 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103871:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103874:	89 04 24             	mov    %eax,(%esp)
80103877:	e8 38 ff ff ff       	call   801037b4 <mpconfig>
8010387c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010387f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103883:	0f 84 9c 01 00 00    	je     80103a25 <mpinit+0x1c4>
    return;
  ismp = 1;
80103889:	c7 05 64 19 11 80 01 	movl   $0x1,0x80111964
80103890:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103893:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103896:	8b 40 24             	mov    0x24(%eax),%eax
80103899:	a3 dc 18 11 80       	mov    %eax,0x801118dc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010389e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a1:	83 c0 2c             	add    $0x2c,%eax
801038a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801038a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038aa:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801038ae:	0f b7 c0             	movzwl %ax,%eax
801038b1:	03 45 f0             	add    -0x10(%ebp),%eax
801038b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801038b7:	e9 f4 00 00 00       	jmp    801039b0 <mpinit+0x14f>
    switch(*p){
801038bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038bf:	0f b6 00             	movzbl (%eax),%eax
801038c2:	0f b6 c0             	movzbl %al,%eax
801038c5:	83 f8 04             	cmp    $0x4,%eax
801038c8:	0f 87 bf 00 00 00    	ja     8010398d <mpinit+0x12c>
801038ce:	8b 04 85 6c 9a 10 80 	mov    -0x7fef6594(,%eax,4),%eax
801038d5:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801038d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038da:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801038dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038e0:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801038e4:	0f b6 d0             	movzbl %al,%edx
801038e7:	a1 60 1f 11 80       	mov    0x80111f60,%eax
801038ec:	39 c2                	cmp    %eax,%edx
801038ee:	74 2d                	je     8010391d <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801038f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038f3:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801038f7:	0f b6 d0             	movzbl %al,%edx
801038fa:	a1 60 1f 11 80       	mov    0x80111f60,%eax
801038ff:	89 54 24 08          	mov    %edx,0x8(%esp)
80103903:	89 44 24 04          	mov    %eax,0x4(%esp)
80103907:	c7 04 24 2e 9a 10 80 	movl   $0x80109a2e,(%esp)
8010390e:	e8 8e ca ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103913:	c7 05 64 19 11 80 00 	movl   $0x0,0x80111964
8010391a:	00 00 00 
      }
      if(proc->flags & MPBOOT)
8010391d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103920:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103924:	0f b6 c0             	movzbl %al,%eax
80103927:	83 e0 02             	and    $0x2,%eax
8010392a:	85 c0                	test   %eax,%eax
8010392c:	74 15                	je     80103943 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
8010392e:	a1 60 1f 11 80       	mov    0x80111f60,%eax
80103933:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103939:	05 80 19 11 80       	add    $0x80111980,%eax
8010393e:	a3 a4 d6 10 80       	mov    %eax,0x8010d6a4
      cpus[ncpu].id = ncpu;
80103943:	8b 15 60 1f 11 80    	mov    0x80111f60,%edx
80103949:	a1 60 1f 11 80       	mov    0x80111f60,%eax
8010394e:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103954:	81 c2 80 19 11 80    	add    $0x80111980,%edx
8010395a:	88 02                	mov    %al,(%edx)
      ncpu++;
8010395c:	a1 60 1f 11 80       	mov    0x80111f60,%eax
80103961:	83 c0 01             	add    $0x1,%eax
80103964:	a3 60 1f 11 80       	mov    %eax,0x80111f60
      p += sizeof(struct mpproc);
80103969:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010396d:	eb 41                	jmp    801039b0 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010396f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103972:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103975:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103978:	0f b6 40 01          	movzbl 0x1(%eax),%eax
8010397c:	a2 60 19 11 80       	mov    %al,0x80111960
      p += sizeof(struct mpioapic);
80103981:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103985:	eb 29                	jmp    801039b0 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103987:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010398b:	eb 23                	jmp    801039b0 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
8010398d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103990:	0f b6 00             	movzbl (%eax),%eax
80103993:	0f b6 c0             	movzbl %al,%eax
80103996:	89 44 24 04          	mov    %eax,0x4(%esp)
8010399a:	c7 04 24 4c 9a 10 80 	movl   $0x80109a4c,(%esp)
801039a1:	e8 fb c9 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
801039a6:	c7 05 64 19 11 80 00 	movl   $0x0,0x80111964
801039ad:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801039b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039b6:	0f 82 00 ff ff ff    	jb     801038bc <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801039bc:	a1 64 19 11 80       	mov    0x80111964,%eax
801039c1:	85 c0                	test   %eax,%eax
801039c3:	75 1d                	jne    801039e2 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801039c5:	c7 05 60 1f 11 80 01 	movl   $0x1,0x80111f60
801039cc:	00 00 00 
    lapic = 0;
801039cf:	c7 05 dc 18 11 80 00 	movl   $0x0,0x801118dc
801039d6:	00 00 00 
    ioapicid = 0;
801039d9:	c6 05 60 19 11 80 00 	movb   $0x0,0x80111960
    return;
801039e0:	eb 44                	jmp    80103a26 <mpinit+0x1c5>
  }

  if(mp->imcrp){
801039e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801039e5:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801039e9:	84 c0                	test   %al,%al
801039eb:	74 39                	je     80103a26 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801039ed:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
801039f4:	00 
801039f5:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
801039fc:	e8 12 fc ff ff       	call   80103613 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103a01:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a08:	e8 dc fb ff ff       	call   801035e9 <inb>
80103a0d:	83 c8 01             	or     $0x1,%eax
80103a10:	0f b6 c0             	movzbl %al,%eax
80103a13:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a17:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a1e:	e8 f0 fb ff ff       	call   80103613 <outb>
80103a23:	eb 01                	jmp    80103a26 <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103a25:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103a26:	c9                   	leave  
80103a27:	c3                   	ret    

80103a28 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a28:	55                   	push   %ebp
80103a29:	89 e5                	mov    %esp,%ebp
80103a2b:	83 ec 08             	sub    $0x8,%esp
80103a2e:	8b 55 08             	mov    0x8(%ebp),%edx
80103a31:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a34:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a38:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a3b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a3f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a43:	ee                   	out    %al,(%dx)
}
80103a44:	c9                   	leave  
80103a45:	c3                   	ret    

80103a46 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103a46:	55                   	push   %ebp
80103a47:	89 e5                	mov    %esp,%ebp
80103a49:	83 ec 0c             	sub    $0xc,%esp
80103a4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103a53:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a57:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
  outb(IO_PIC1+1, mask);
80103a5d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a61:	0f b6 c0             	movzbl %al,%eax
80103a64:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a68:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103a6f:	e8 b4 ff ff ff       	call   80103a28 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103a74:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103a78:	66 c1 e8 08          	shr    $0x8,%ax
80103a7c:	0f b6 c0             	movzbl %al,%eax
80103a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a83:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103a8a:	e8 99 ff ff ff       	call   80103a28 <outb>
}
80103a8f:	c9                   	leave  
80103a90:	c3                   	ret    

80103a91 <picenable>:

void
picenable(int irq)
{
80103a91:	55                   	push   %ebp
80103a92:	89 e5                	mov    %esp,%ebp
80103a94:	53                   	push   %ebx
80103a95:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103a98:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9b:	ba 01 00 00 00       	mov    $0x1,%edx
80103aa0:	89 d3                	mov    %edx,%ebx
80103aa2:	89 c1                	mov    %eax,%ecx
80103aa4:	d3 e3                	shl    %cl,%ebx
80103aa6:	89 d8                	mov    %ebx,%eax
80103aa8:	89 c2                	mov    %eax,%edx
80103aaa:	f7 d2                	not    %edx
80103aac:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80103ab3:	21 d0                	and    %edx,%eax
80103ab5:	0f b7 c0             	movzwl %ax,%eax
80103ab8:	89 04 24             	mov    %eax,(%esp)
80103abb:	e8 86 ff ff ff       	call   80103a46 <picsetmask>
}
80103ac0:	83 c4 04             	add    $0x4,%esp
80103ac3:	5b                   	pop    %ebx
80103ac4:	5d                   	pop    %ebp
80103ac5:	c3                   	ret    

80103ac6 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103ac6:	55                   	push   %ebp
80103ac7:	89 e5                	mov    %esp,%ebp
80103ac9:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103acc:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ad3:	00 
80103ad4:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103adb:	e8 48 ff ff ff       	call   80103a28 <outb>
  outb(IO_PIC2+1, 0xFF);
80103ae0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ae7:	00 
80103ae8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103aef:	e8 34 ff ff ff       	call   80103a28 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103af4:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103afb:	00 
80103afc:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103b03:	e8 20 ff ff ff       	call   80103a28 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103b08:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103b0f:	00 
80103b10:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b17:	e8 0c ff ff ff       	call   80103a28 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103b1c:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103b23:	00 
80103b24:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b2b:	e8 f8 fe ff ff       	call   80103a28 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103b30:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b37:	00 
80103b38:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b3f:	e8 e4 fe ff ff       	call   80103a28 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103b44:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b4b:	00 
80103b4c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103b53:	e8 d0 fe ff ff       	call   80103a28 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103b58:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103b5f:	00 
80103b60:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b67:	e8 bc fe ff ff       	call   80103a28 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103b6c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103b73:	00 
80103b74:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b7b:	e8 a8 fe ff ff       	call   80103a28 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103b80:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b87:	00 
80103b88:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b8f:	e8 94 fe ff ff       	call   80103a28 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103b94:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103b9b:	00 
80103b9c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ba3:	e8 80 fe ff ff       	call   80103a28 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ba8:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103baf:	00 
80103bb0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103bb7:	e8 6c fe ff ff       	call   80103a28 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103bbc:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103bc3:	00 
80103bc4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bcb:	e8 58 fe ff ff       	call   80103a28 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103bd0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103bd7:	00 
80103bd8:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bdf:	e8 44 fe ff ff       	call   80103a28 <outb>

  if(irqmask != 0xFFFF)
80103be4:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80103beb:	66 83 f8 ff          	cmp    $0xffff,%ax
80103bef:	74 12                	je     80103c03 <picinit+0x13d>
    picsetmask(irqmask);
80103bf1:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80103bf8:	0f b7 c0             	movzwl %ax,%eax
80103bfb:	89 04 24             	mov    %eax,(%esp)
80103bfe:	e8 43 fe ff ff       	call   80103a46 <picsetmask>
}
80103c03:	c9                   	leave  
80103c04:	c3                   	ret    
80103c05:	00 00                	add    %al,(%eax)
	...

80103c08 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103c08:	55                   	push   %ebp
80103c09:	89 e5                	mov    %esp,%ebp
80103c0b:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103c0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103c15:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c21:	8b 10                	mov    (%eax),%edx
80103c23:	8b 45 08             	mov    0x8(%ebp),%eax
80103c26:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103c28:	e8 ef d2 ff ff       	call   80100f1c <filealloc>
80103c2d:	8b 55 08             	mov    0x8(%ebp),%edx
80103c30:	89 02                	mov    %eax,(%edx)
80103c32:	8b 45 08             	mov    0x8(%ebp),%eax
80103c35:	8b 00                	mov    (%eax),%eax
80103c37:	85 c0                	test   %eax,%eax
80103c39:	0f 84 c8 00 00 00    	je     80103d07 <pipealloc+0xff>
80103c3f:	e8 d8 d2 ff ff       	call   80100f1c <filealloc>
80103c44:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c47:	89 02                	mov    %eax,(%edx)
80103c49:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c4c:	8b 00                	mov    (%eax),%eax
80103c4e:	85 c0                	test   %eax,%eax
80103c50:	0f 84 b1 00 00 00    	je     80103d07 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c56:	e8 98 ee ff ff       	call   80102af3 <kalloc>
80103c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c62:	0f 84 9e 00 00 00    	je     80103d06 <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6b:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c72:	00 00 00 
  p->writeopen = 1;
80103c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c78:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c7f:	00 00 00 
  p->nwrite = 0;
80103c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c85:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103c8c:	00 00 00 
  p->nread = 0;
80103c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c92:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103c99:	00 00 00 
  initlock(&p->lock, "pipe");
80103c9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9f:	c7 44 24 04 80 9a 10 	movl   $0x80109a80,0x4(%esp)
80103ca6:	80 
80103ca7:	89 04 24             	mov    %eax,(%esp)
80103caa:	e8 33 23 00 00       	call   80105fe2 <initlock>
  (*f0)->type = FD_PIPE;
80103caf:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb2:	8b 00                	mov    (%eax),%eax
80103cb4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103cba:	8b 45 08             	mov    0x8(%ebp),%eax
80103cbd:	8b 00                	mov    (%eax),%eax
80103cbf:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cc6:	8b 00                	mov    (%eax),%eax
80103cc8:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103ccc:	8b 45 08             	mov    0x8(%ebp),%eax
80103ccf:	8b 00                	mov    (%eax),%eax
80103cd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cd4:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cda:	8b 00                	mov    (%eax),%eax
80103cdc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce5:	8b 00                	mov    (%eax),%eax
80103ce7:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cee:	8b 00                	mov    (%eax),%eax
80103cf0:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103cf4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cf7:	8b 00                	mov    (%eax),%eax
80103cf9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cfc:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103cff:	b8 00 00 00 00       	mov    $0x0,%eax
80103d04:	eb 43                	jmp    80103d49 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103d06:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103d07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d0b:	74 0b                	je     80103d18 <pipealloc+0x110>
    kfree((char*)p);
80103d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d10:	89 04 24             	mov    %eax,(%esp)
80103d13:	e8 42 ed ff ff       	call   80102a5a <kfree>
  if(*f0)
80103d18:	8b 45 08             	mov    0x8(%ebp),%eax
80103d1b:	8b 00                	mov    (%eax),%eax
80103d1d:	85 c0                	test   %eax,%eax
80103d1f:	74 0d                	je     80103d2e <pipealloc+0x126>
    fileclose(*f0);
80103d21:	8b 45 08             	mov    0x8(%ebp),%eax
80103d24:	8b 00                	mov    (%eax),%eax
80103d26:	89 04 24             	mov    %eax,(%esp)
80103d29:	e8 96 d2 ff ff       	call   80100fc4 <fileclose>
  if(*f1)
80103d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d31:	8b 00                	mov    (%eax),%eax
80103d33:	85 c0                	test   %eax,%eax
80103d35:	74 0d                	je     80103d44 <pipealloc+0x13c>
    fileclose(*f1);
80103d37:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d3a:	8b 00                	mov    (%eax),%eax
80103d3c:	89 04 24             	mov    %eax,(%esp)
80103d3f:	e8 80 d2 ff ff       	call   80100fc4 <fileclose>
  return -1;
80103d44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d49:	c9                   	leave  
80103d4a:	c3                   	ret    

80103d4b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d4b:	55                   	push   %ebp
80103d4c:	89 e5                	mov    %esp,%ebp
80103d4e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103d51:	8b 45 08             	mov    0x8(%ebp),%eax
80103d54:	89 04 24             	mov    %eax,(%esp)
80103d57:	e8 a7 22 00 00       	call   80106003 <acquire>
  if(writable){
80103d5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d60:	74 1f                	je     80103d81 <pipeclose+0x36>
    p->writeopen = 0;
80103d62:	8b 45 08             	mov    0x8(%ebp),%eax
80103d65:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d6c:	00 00 00 
    wakeup(&p->nread);
80103d6f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d72:	05 34 02 00 00       	add    $0x234,%eax
80103d77:	89 04 24             	mov    %eax,(%esp)
80103d7a:	e8 19 0d 00 00       	call   80104a98 <wakeup>
80103d7f:	eb 1d                	jmp    80103d9e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103d81:	8b 45 08             	mov    0x8(%ebp),%eax
80103d84:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103d8b:	00 00 00 
    wakeup(&p->nwrite);
80103d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d91:	05 38 02 00 00       	add    $0x238,%eax
80103d96:	89 04 24             	mov    %eax,(%esp)
80103d99:	e8 fa 0c 00 00       	call   80104a98 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80103da1:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103da7:	85 c0                	test   %eax,%eax
80103da9:	75 25                	jne    80103dd0 <pipeclose+0x85>
80103dab:	8b 45 08             	mov    0x8(%ebp),%eax
80103dae:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103db4:	85 c0                	test   %eax,%eax
80103db6:	75 18                	jne    80103dd0 <pipeclose+0x85>
    release(&p->lock);
80103db8:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbb:	89 04 24             	mov    %eax,(%esp)
80103dbe:	e8 b8 22 00 00       	call   8010607b <release>
    kfree((char*)p);
80103dc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc6:	89 04 24             	mov    %eax,(%esp)
80103dc9:	e8 8c ec ff ff       	call   80102a5a <kfree>
80103dce:	eb 0b                	jmp    80103ddb <pipeclose+0x90>
  } else
    release(&p->lock);
80103dd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd3:	89 04 24             	mov    %eax,(%esp)
80103dd6:	e8 a0 22 00 00       	call   8010607b <release>
}
80103ddb:	c9                   	leave  
80103ddc:	c3                   	ret    

80103ddd <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103ddd:	55                   	push   %ebp
80103dde:	89 e5                	mov    %esp,%ebp
80103de0:	53                   	push   %ebx
80103de1:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103de4:	8b 45 08             	mov    0x8(%ebp),%eax
80103de7:	89 04 24             	mov    %eax,(%esp)
80103dea:	e8 14 22 00 00       	call   80106003 <acquire>
  for(i = 0; i < n; i++){
80103def:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103df6:	e9 a6 00 00 00       	jmp    80103ea1 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80103dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dfe:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103e04:	85 c0                	test   %eax,%eax
80103e06:	74 0d                	je     80103e15 <pipewrite+0x38>
80103e08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103e0e:	8b 40 24             	mov    0x24(%eax),%eax
80103e11:	85 c0                	test   %eax,%eax
80103e13:	74 15                	je     80103e2a <pipewrite+0x4d>
        release(&p->lock);
80103e15:	8b 45 08             	mov    0x8(%ebp),%eax
80103e18:	89 04 24             	mov    %eax,(%esp)
80103e1b:	e8 5b 22 00 00       	call   8010607b <release>
        return -1;
80103e20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e25:	e9 9d 00 00 00       	jmp    80103ec7 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2d:	05 34 02 00 00       	add    $0x234,%eax
80103e32:	89 04 24             	mov    %eax,(%esp)
80103e35:	e8 5e 0c 00 00       	call   80104a98 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3d:	8b 55 08             	mov    0x8(%ebp),%edx
80103e40:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e46:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e4a:	89 14 24             	mov    %edx,(%esp)
80103e4d:	e8 07 0b 00 00       	call   80104959 <sleep>
80103e52:	eb 01                	jmp    80103e55 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e54:	90                   	nop
80103e55:	8b 45 08             	mov    0x8(%ebp),%eax
80103e58:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e5e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e61:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e67:	05 00 02 00 00       	add    $0x200,%eax
80103e6c:	39 c2                	cmp    %eax,%edx
80103e6e:	74 8b                	je     80103dfb <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103e70:	8b 45 08             	mov    0x8(%ebp),%eax
80103e73:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103e79:	89 c3                	mov    %eax,%ebx
80103e7b:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103e81:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e84:	03 55 0c             	add    0xc(%ebp),%edx
80103e87:	0f b6 0a             	movzbl (%edx),%ecx
80103e8a:	8b 55 08             	mov    0x8(%ebp),%edx
80103e8d:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80103e91:	8d 50 01             	lea    0x1(%eax),%edx
80103e94:	8b 45 08             	mov    0x8(%ebp),%eax
80103e97:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103e9d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea4:	3b 45 10             	cmp    0x10(%ebp),%eax
80103ea7:	7c ab                	jl     80103e54 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103ea9:	8b 45 08             	mov    0x8(%ebp),%eax
80103eac:	05 34 02 00 00       	add    $0x234,%eax
80103eb1:	89 04 24             	mov    %eax,(%esp)
80103eb4:	e8 df 0b 00 00       	call   80104a98 <wakeup>
  release(&p->lock);
80103eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ebc:	89 04 24             	mov    %eax,(%esp)
80103ebf:	e8 b7 21 00 00       	call   8010607b <release>
  return n;
80103ec4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103ec7:	83 c4 24             	add    $0x24,%esp
80103eca:	5b                   	pop    %ebx
80103ecb:	5d                   	pop    %ebp
80103ecc:	c3                   	ret    

80103ecd <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103ecd:	55                   	push   %ebp
80103ece:	89 e5                	mov    %esp,%ebp
80103ed0:	53                   	push   %ebx
80103ed1:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed7:	89 04 24             	mov    %eax,(%esp)
80103eda:	e8 24 21 00 00       	call   80106003 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103edf:	eb 3a                	jmp    80103f1b <piperead+0x4e>
    if(proc->killed){
80103ee1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ee7:	8b 40 24             	mov    0x24(%eax),%eax
80103eea:	85 c0                	test   %eax,%eax
80103eec:	74 15                	je     80103f03 <piperead+0x36>
      release(&p->lock);
80103eee:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef1:	89 04 24             	mov    %eax,(%esp)
80103ef4:	e8 82 21 00 00       	call   8010607b <release>
      return -1;
80103ef9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103efe:	e9 b6 00 00 00       	jmp    80103fb9 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103f03:	8b 45 08             	mov    0x8(%ebp),%eax
80103f06:	8b 55 08             	mov    0x8(%ebp),%edx
80103f09:	81 c2 34 02 00 00    	add    $0x234,%edx
80103f0f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f13:	89 14 24             	mov    %edx,(%esp)
80103f16:	e8 3e 0a 00 00       	call   80104959 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f24:	8b 45 08             	mov    0x8(%ebp),%eax
80103f27:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f2d:	39 c2                	cmp    %eax,%edx
80103f2f:	75 0d                	jne    80103f3e <piperead+0x71>
80103f31:	8b 45 08             	mov    0x8(%ebp),%eax
80103f34:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f3a:	85 c0                	test   %eax,%eax
80103f3c:	75 a3                	jne    80103ee1 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f45:	eb 49                	jmp    80103f90 <piperead+0xc3>
    if(p->nread == p->nwrite)
80103f47:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f50:	8b 45 08             	mov    0x8(%ebp),%eax
80103f53:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f59:	39 c2                	cmp    %eax,%edx
80103f5b:	74 3d                	je     80103f9a <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f60:	89 c2                	mov    %eax,%edx
80103f62:	03 55 0c             	add    0xc(%ebp),%edx
80103f65:	8b 45 08             	mov    0x8(%ebp),%eax
80103f68:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f6e:	89 c3                	mov    %eax,%ebx
80103f70:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103f76:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f79:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80103f7e:	88 0a                	mov    %cl,(%edx)
80103f80:	8d 50 01             	lea    0x1(%eax),%edx
80103f83:	8b 45 08             	mov    0x8(%ebp),%eax
80103f86:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f93:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f96:	7c af                	jl     80103f47 <piperead+0x7a>
80103f98:	eb 01                	jmp    80103f9b <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80103f9a:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9e:	05 38 02 00 00       	add    $0x238,%eax
80103fa3:	89 04 24             	mov    %eax,(%esp)
80103fa6:	e8 ed 0a 00 00       	call   80104a98 <wakeup>
  release(&p->lock);
80103fab:	8b 45 08             	mov    0x8(%ebp),%eax
80103fae:	89 04 24             	mov    %eax,(%esp)
80103fb1:	e8 c5 20 00 00       	call   8010607b <release>
  return i;
80103fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103fb9:	83 c4 24             	add    $0x24,%esp
80103fbc:	5b                   	pop    %ebx
80103fbd:	5d                   	pop    %ebp
80103fbe:	c3                   	ret    
	...

80103fc0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80103fc0:	55                   	push   %ebp
80103fc1:	89 e5                	mov    %esp,%ebp
80103fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc6:	05 00 00 00 80       	add    $0x80000000,%eax
80103fcb:	5d                   	pop    %ebp
80103fcc:	c3                   	ret    

80103fcd <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103fcd:	55                   	push   %ebp
80103fce:	89 e5                	mov    %esp,%ebp
80103fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd3:	05 00 00 00 80       	add    $0x80000000,%eax
80103fd8:	5d                   	pop    %ebp
80103fd9:	c3                   	ret    

80103fda <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103fda:	55                   	push   %ebp
80103fdb:	89 e5                	mov    %esp,%ebp
80103fdd:	53                   	push   %ebx
80103fde:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fe1:	9c                   	pushf  
80103fe2:	5b                   	pop    %ebx
80103fe3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80103fe6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103fe9:	83 c4 10             	add    $0x10,%esp
80103fec:	5b                   	pop    %ebx
80103fed:	5d                   	pop    %ebp
80103fee:	c3                   	ret    

80103fef <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80103fef:	55                   	push   %ebp
80103ff0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103ff2:	fb                   	sti    
}
80103ff3:	5d                   	pop    %ebp
80103ff4:	c3                   	ret    

80103ff5 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103ff5:	55                   	push   %ebp
80103ff6:	89 e5                	mov    %esp,%ebp
80103ff8:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103ffb:	c7 44 24 04 88 9a 10 	movl   $0x80109a88,0x4(%esp)
80104002:	80 
80104003:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
8010400a:	e8 d3 1f 00 00       	call   80105fe2 <initlock>
}
8010400f:	c9                   	leave  
80104010:	c3                   	ret    

80104011 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104011:	55                   	push   %ebp
80104012:	89 e5                	mov    %esp,%ebp
80104014:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104017:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
8010401e:	e8 e0 1f 00 00       	call   80106003 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104023:	c7 45 f4 f4 4f 14 80 	movl   $0x80144ff4,-0xc(%ebp)
8010402a:	eb 11                	jmp    8010403d <allocproc+0x2c>
    if(p->state == UNUSED)
8010402c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402f:	8b 40 0c             	mov    0xc(%eax),%eax
80104032:	85 c0                	test   %eax,%eax
80104034:	74 26                	je     8010405c <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104036:	81 45 f4 88 10 00 00 	addl   $0x1088,-0xc(%ebp)
8010403d:	81 7d f4 f4 71 18 80 	cmpl   $0x801871f4,-0xc(%ebp)
80104044:	72 e6                	jb     8010402c <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104046:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
8010404d:	e8 29 20 00 00       	call   8010607b <release>
  return 0;
80104052:	b8 00 00 00 00       	mov    $0x0,%eax
80104057:	e9 b5 00 00 00       	jmp    80104111 <allocproc+0x100>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
8010405c:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010405d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104060:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104067:	a1 20 d0 10 80       	mov    0x8010d020,%eax
8010406c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010406f:	89 42 10             	mov    %eax,0x10(%edx)
80104072:	83 c0 01             	add    $0x1,%eax
80104075:	a3 20 d0 10 80       	mov    %eax,0x8010d020
  release(&ptable.lock);
8010407a:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104081:	e8 f5 1f 00 00       	call   8010607b <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104086:	e8 68 ea ff ff       	call   80102af3 <kalloc>
8010408b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010408e:	89 42 08             	mov    %eax,0x8(%edx)
80104091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104094:	8b 40 08             	mov    0x8(%eax),%eax
80104097:	85 c0                	test   %eax,%eax
80104099:	75 11                	jne    801040ac <allocproc+0x9b>
    p->state = UNUSED;
8010409b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801040a5:	b8 00 00 00 00       	mov    $0x0,%eax
801040aa:	eb 65                	jmp    80104111 <allocproc+0x100>
  }
  sp = p->kstack + KSTACKSIZE;
801040ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040af:	8b 40 08             	mov    0x8(%eax),%eax
801040b2:	05 00 10 00 00       	add    $0x1000,%eax
801040b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801040ba:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801040be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040c4:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801040c7:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801040cb:	ba 78 78 10 80       	mov    $0x80107878,%edx
801040d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040d3:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801040d5:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801040d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040df:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801040e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e5:	8b 40 1c             	mov    0x1c(%eax),%eax
801040e8:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801040ef:	00 
801040f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801040f7:	00 
801040f8:	89 04 24             	mov    %eax,(%esp)
801040fb:	e8 66 21 00 00       	call   80106266 <memset>
  p->context->eip = (uint)forkret;
80104100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104103:	8b 40 1c             	mov    0x1c(%eax),%eax
80104106:	ba 2d 49 10 80       	mov    $0x8010492d,%edx
8010410b:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010410e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104111:	c9                   	leave  
80104112:	c3                   	ret    

80104113 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104113:	55                   	push   %ebp
80104114:	89 e5                	mov    %esp,%ebp
80104116:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104119:	e8 f3 fe ff ff       	call   80104011 <allocproc>
8010411e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104124:	a3 ac d6 10 80       	mov    %eax,0x8010d6ac
  if((p->pgdir = setupkvm(kalloc)) == 0)
80104129:	c7 04 24 f3 2a 10 80 	movl   $0x80102af3,(%esp)
80104130:	e8 40 4e 00 00       	call   80108f75 <setupkvm>
80104135:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104138:	89 42 04             	mov    %eax,0x4(%edx)
8010413b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010413e:	8b 40 04             	mov    0x4(%eax),%eax
80104141:	85 c0                	test   %eax,%eax
80104143:	75 0c                	jne    80104151 <userinit+0x3e>
    panic("userinit: out of memory?");
80104145:	c7 04 24 8f 9a 10 80 	movl   $0x80109a8f,(%esp)
8010414c:	e8 ec c3 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104151:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104159:	8b 40 04             	mov    0x4(%eax),%eax
8010415c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104160:	c7 44 24 04 40 d5 10 	movl   $0x8010d540,0x4(%esp)
80104167:	80 
80104168:	89 04 24             	mov    %eax,(%esp)
8010416b:	e8 5d 50 00 00       	call   801091cd <inituvm>
  p->sz = PGSIZE;
80104170:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104173:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104179:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010417c:	8b 40 18             	mov    0x18(%eax),%eax
8010417f:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104186:	00 
80104187:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010418e:	00 
8010418f:	89 04 24             	mov    %eax,(%esp)
80104192:	e8 cf 20 00 00       	call   80106266 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104197:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419a:	8b 40 18             	mov    0x18(%eax),%eax
8010419d:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801041a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a6:	8b 40 18             	mov    0x18(%eax),%eax
801041a9:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801041af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b2:	8b 40 18             	mov    0x18(%eax),%eax
801041b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041b8:	8b 52 18             	mov    0x18(%edx),%edx
801041bb:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801041bf:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801041c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c6:	8b 40 18             	mov    0x18(%eax),%eax
801041c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041cc:	8b 52 18             	mov    0x18(%edx),%edx
801041cf:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801041d3:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801041d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041da:	8b 40 18             	mov    0x18(%eax),%eax
801041dd:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801041e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e7:	8b 40 18             	mov    0x18(%eax),%eax
801041ea:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801041f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f4:	8b 40 18             	mov    0x18(%eax),%eax
801041f7:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801041fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104201:	83 c0 6c             	add    $0x6c,%eax
80104204:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010420b:	00 
8010420c:	c7 44 24 04 a8 9a 10 	movl   $0x80109aa8,0x4(%esp)
80104213:	80 
80104214:	89 04 24             	mov    %eax,(%esp)
80104217:	e8 7a 22 00 00       	call   80106496 <safestrcpy>
  p->cwd = namei("/");
8010421c:	c7 04 24 b1 9a 10 80 	movl   $0x80109ab1,(%esp)
80104223:	e8 e2 e1 ff ff       	call   8010240a <namei>
80104228:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010422b:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
8010422e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104231:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  createInternalProcess("inSwapper",(void*)inSwapper);
80104238:	c7 44 24 04 bd 57 10 	movl   $0x801057bd,0x4(%esp)
8010423f:	80 
80104240:	c7 04 24 b3 9a 10 80 	movl   $0x80109ab3,(%esp)
80104247:	e8 05 0a 00 00       	call   80104c51 <createInternalProcess>
}
8010424c:	c9                   	leave  
8010424d:	c3                   	ret    

8010424e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010424e:	55                   	push   %ebp
8010424f:	89 e5                	mov    %esp,%ebp
80104251:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104254:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010425a:	8b 00                	mov    (%eax),%eax
8010425c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010425f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104263:	7e 34                	jle    80104299 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104265:	8b 45 08             	mov    0x8(%ebp),%eax
80104268:	89 c2                	mov    %eax,%edx
8010426a:	03 55 f4             	add    -0xc(%ebp),%edx
8010426d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104273:	8b 40 04             	mov    0x4(%eax),%eax
80104276:	89 54 24 08          	mov    %edx,0x8(%esp)
8010427a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010427d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104281:	89 04 24             	mov    %eax,(%esp)
80104284:	e8 be 50 00 00       	call   80109347 <allocuvm>
80104289:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010428c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104290:	75 41                	jne    801042d3 <growproc+0x85>
      return -1;
80104292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104297:	eb 58                	jmp    801042f1 <growproc+0xa3>
  } else if(n < 0){
80104299:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010429d:	79 34                	jns    801042d3 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010429f:	8b 45 08             	mov    0x8(%ebp),%eax
801042a2:	89 c2                	mov    %eax,%edx
801042a4:	03 55 f4             	add    -0xc(%ebp),%edx
801042a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042ad:	8b 40 04             	mov    0x4(%eax),%eax
801042b0:	89 54 24 08          	mov    %edx,0x8(%esp)
801042b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801042bb:	89 04 24             	mov    %eax,(%esp)
801042be:	e8 52 51 00 00       	call   80109415 <deallocuvm>
801042c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042ca:	75 07                	jne    801042d3 <growproc+0x85>
      return -1;
801042cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042d1:	eb 1e                	jmp    801042f1 <growproc+0xa3>
  }
  proc->sz = sz;
801042d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042dc:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801042de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042e4:	89 04 24             	mov    %eax,(%esp)
801042e7:	e8 7a 4d 00 00       	call   80109066 <switchuvm>
  return 0;
801042ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042f1:	c9                   	leave  
801042f2:	c3                   	ret    

801042f3 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801042f3:	55                   	push   %ebp
801042f4:	89 e5                	mov    %esp,%ebp
801042f6:	57                   	push   %edi
801042f7:	56                   	push   %esi
801042f8:	53                   	push   %ebx
801042f9:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801042fc:	e8 10 fd ff ff       	call   80104011 <allocproc>
80104301:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104304:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104308:	75 0a                	jne    80104314 <fork+0x21>
    return -1;
8010430a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010430f:	e9 3a 01 00 00       	jmp    8010444e <fork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104314:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010431a:	8b 10                	mov    (%eax),%edx
8010431c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104322:	8b 40 04             	mov    0x4(%eax),%eax
80104325:	89 54 24 04          	mov    %edx,0x4(%esp)
80104329:	89 04 24             	mov    %eax,(%esp)
8010432c:	e8 74 52 00 00       	call   801095a5 <copyuvm>
80104331:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104334:	89 42 04             	mov    %eax,0x4(%edx)
80104337:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010433a:	8b 40 04             	mov    0x4(%eax),%eax
8010433d:	85 c0                	test   %eax,%eax
8010433f:	75 2c                	jne    8010436d <fork+0x7a>
    kfree(np->kstack);
80104341:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104344:	8b 40 08             	mov    0x8(%eax),%eax
80104347:	89 04 24             	mov    %eax,(%esp)
8010434a:	e8 0b e7 ff ff       	call   80102a5a <kfree>
    np->kstack = 0;
8010434f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104352:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104359:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010435c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104363:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104368:	e9 e1 00 00 00       	jmp    8010444e <fork+0x15b>
  }
  np->sz = proc->sz;
8010436d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104373:	8b 10                	mov    (%eax),%edx
80104375:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104378:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010437a:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104381:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104384:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104387:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010438a:	8b 50 18             	mov    0x18(%eax),%edx
8010438d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104393:	8b 40 18             	mov    0x18(%eax),%eax
80104396:	89 c3                	mov    %eax,%ebx
80104398:	b8 13 00 00 00       	mov    $0x13,%eax
8010439d:	89 d7                	mov    %edx,%edi
8010439f:	89 de                	mov    %ebx,%esi
801043a1:	89 c1                	mov    %eax,%ecx
801043a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801043a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043a8:	8b 40 18             	mov    0x18(%eax),%eax
801043ab:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801043b2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801043b9:	eb 3d                	jmp    801043f8 <fork+0x105>
    if(proc->ofile[i])
801043bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801043c4:	83 c2 08             	add    $0x8,%edx
801043c7:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043cb:	85 c0                	test   %eax,%eax
801043cd:	74 25                	je     801043f4 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801043cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801043d8:	83 c2 08             	add    $0x8,%edx
801043db:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043df:	89 04 24             	mov    %eax,(%esp)
801043e2:	e8 95 cb ff ff       	call   80100f7c <filedup>
801043e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801043ea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801043ed:	83 c1 08             	add    $0x8,%ecx
801043f0:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801043f4:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801043f8:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801043fc:	7e bd                	jle    801043bb <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801043fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104404:	8b 40 68             	mov    0x68(%eax),%eax
80104407:	89 04 24             	mov    %eax,(%esp)
8010440a:	e8 27 d4 ff ff       	call   80101836 <idup>
8010440f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104412:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104415:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104418:	8b 40 10             	mov    0x10(%eax),%eax
8010441b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
8010441e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104421:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104428:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010442e:	8d 50 6c             	lea    0x6c(%eax),%edx
80104431:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104434:	83 c0 6c             	add    $0x6c,%eax
80104437:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010443e:	00 
8010443f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104443:	89 04 24             	mov    %eax,(%esp)
80104446:	e8 4b 20 00 00       	call   80106496 <safestrcpy>
  return pid;
8010444b:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010444e:	83 c4 2c             	add    $0x2c,%esp
80104451:	5b                   	pop    %ebx
80104452:	5e                   	pop    %esi
80104453:	5f                   	pop    %edi
80104454:	5d                   	pop    %ebp
80104455:	c3                   	ret    

80104456 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104456:	55                   	push   %ebp
80104457:	89 e5                	mov    %esp,%ebp
80104459:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010445c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104463:	a1 ac d6 10 80       	mov    0x8010d6ac,%eax
80104468:	39 c2                	cmp    %eax,%edx
8010446a:	75 0c                	jne    80104478 <exit+0x22>
    panic("init exiting");
8010446c:	c7 04 24 bd 9a 10 80 	movl   $0x80109abd,(%esp)
80104473:	e8 c5 c0 ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104478:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010447f:	eb 44                	jmp    801044c5 <exit+0x6f>
    if(proc->ofile[fd]){
80104481:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104487:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010448a:	83 c2 08             	add    $0x8,%edx
8010448d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104491:	85 c0                	test   %eax,%eax
80104493:	74 2c                	je     801044c1 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104495:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010449b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010449e:	83 c2 08             	add    $0x8,%edx
801044a1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801044a5:	89 04 24             	mov    %eax,(%esp)
801044a8:	e8 17 cb ff ff       	call   80100fc4 <fileclose>
      proc->ofile[fd] = 0;
801044ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044b6:	83 c2 08             	add    $0x8,%edx
801044b9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801044c0:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801044c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801044c5:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801044c9:	7e b6                	jle    80104481 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
801044cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044d1:	8b 40 68             	mov    0x68(%eax),%eax
801044d4:	89 04 24             	mov    %eax,(%esp)
801044d7:	e8 3f d5 ff ff       	call   80101a1b <iput>
  proc->cwd = 0;
801044dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044e2:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801044e9:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
801044f0:	e8 0e 1b 00 00       	call   80106003 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801044f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044fb:	8b 40 14             	mov    0x14(%eax),%eax
801044fe:	89 04 24             	mov    %eax,(%esp)
80104501:	e8 3a 05 00 00       	call   80104a40 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104506:	c7 45 f4 f4 4f 14 80 	movl   $0x80144ff4,-0xc(%ebp)
8010450d:	eb 3b                	jmp    8010454a <exit+0xf4>
    if(p->parent == proc){
8010450f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104512:	8b 50 14             	mov    0x14(%eax),%edx
80104515:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010451b:	39 c2                	cmp    %eax,%edx
8010451d:	75 24                	jne    80104543 <exit+0xed>
      p->parent = initproc;
8010451f:	8b 15 ac d6 10 80    	mov    0x8010d6ac,%edx
80104525:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104528:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010452b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452e:	8b 40 0c             	mov    0xc(%eax),%eax
80104531:	83 f8 05             	cmp    $0x5,%eax
80104534:	75 0d                	jne    80104543 <exit+0xed>
        wakeup1(initproc);
80104536:	a1 ac d6 10 80       	mov    0x8010d6ac,%eax
8010453b:	89 04 24             	mov    %eax,(%esp)
8010453e:	e8 fd 04 00 00       	call   80104a40 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104543:	81 45 f4 88 10 00 00 	addl   $0x1088,-0xc(%ebp)
8010454a:	81 7d f4 f4 71 18 80 	cmpl   $0x801871f4,-0xc(%ebp)
80104551:	72 bc                	jb     8010450f <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104553:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104559:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104560:	e8 e4 02 00 00       	call   80104849 <sched>
  panic("zombie exit");
80104565:	c7 04 24 ca 9a 10 80 	movl   $0x80109aca,(%esp)
8010456c:	e8 cc bf ff ff       	call   8010053d <panic>

80104571 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104571:	55                   	push   %ebp
80104572:	89 e5                	mov    %esp,%ebp
80104574:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104577:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
8010457e:	e8 80 1a 00 00       	call   80106003 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104583:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010458a:	c7 45 f4 f4 4f 14 80 	movl   $0x80144ff4,-0xc(%ebp)
80104591:	e9 9d 00 00 00       	jmp    80104633 <wait+0xc2>
      if(p->parent != proc)
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	8b 50 14             	mov    0x14(%eax),%edx
8010459c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045a2:	39 c2                	cmp    %eax,%edx
801045a4:	0f 85 81 00 00 00    	jne    8010462b <wait+0xba>
        continue;
      havekids = 1;
801045aa:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b4:	8b 40 0c             	mov    0xc(%eax),%eax
801045b7:	83 f8 05             	cmp    $0x5,%eax
801045ba:	75 70                	jne    8010462c <wait+0xbb>
        // Found one.
        pid = p->pid;
801045bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bf:	8b 40 10             	mov    0x10(%eax),%eax
801045c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801045c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c8:	8b 40 08             	mov    0x8(%eax),%eax
801045cb:	89 04 24             	mov    %eax,(%esp)
801045ce:	e8 87 e4 ff ff       	call   80102a5a <kfree>
        p->kstack = 0;
801045d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e0:	8b 40 04             	mov    0x4(%eax),%eax
801045e3:	89 04 24             	mov    %eax,(%esp)
801045e6:	e8 e6 4e 00 00       	call   801094d1 <freevm>
        p->state = UNUSED;
801045eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ee:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801045f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104602:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460c:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104610:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104613:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
8010461a:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104621:	e8 55 1a 00 00       	call   8010607b <release>
        return pid;
80104626:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104629:	eb 56                	jmp    80104681 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
8010462b:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010462c:	81 45 f4 88 10 00 00 	addl   $0x1088,-0xc(%ebp)
80104633:	81 7d f4 f4 71 18 80 	cmpl   $0x801871f4,-0xc(%ebp)
8010463a:	0f 82 56 ff ff ff    	jb     80104596 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104640:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104644:	74 0d                	je     80104653 <wait+0xe2>
80104646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010464c:	8b 40 24             	mov    0x24(%eax),%eax
8010464f:	85 c0                	test   %eax,%eax
80104651:	74 13                	je     80104666 <wait+0xf5>
      release(&ptable.lock);
80104653:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
8010465a:	e8 1c 1a 00 00       	call   8010607b <release>
      return -1;
8010465f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104664:	eb 1b                	jmp    80104681 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104666:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010466c:	c7 44 24 04 c0 4f 14 	movl   $0x80144fc0,0x4(%esp)
80104673:	80 
80104674:	89 04 24             	mov    %eax,(%esp)
80104677:	e8 dd 02 00 00       	call   80104959 <sleep>
  }
8010467c:	e9 02 ff ff ff       	jmp    80104583 <wait+0x12>
}
80104681:	c9                   	leave  
80104682:	c3                   	ret    

80104683 <register_handler>:

void
register_handler(sighandler_t sighandler)
{
80104683:	55                   	push   %ebp
80104684:	89 e5                	mov    %esp,%ebp
80104686:	83 ec 28             	sub    $0x28,%esp
  char* addr = uva2ka(proc->pgdir, (char*)proc->tf->esp);
80104689:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468f:	8b 40 18             	mov    0x18(%eax),%eax
80104692:	8b 40 44             	mov    0x44(%eax),%eax
80104695:	89 c2                	mov    %eax,%edx
80104697:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010469d:	8b 40 04             	mov    0x4(%eax),%eax
801046a0:	89 54 24 04          	mov    %edx,0x4(%esp)
801046a4:	89 04 24             	mov    %eax,(%esp)
801046a7:	e8 0a 50 00 00       	call   801096b6 <uva2ka>
801046ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if ((proc->tf->esp & 0xFFF) == 0)
801046af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046b5:	8b 40 18             	mov    0x18(%eax),%eax
801046b8:	8b 40 44             	mov    0x44(%eax),%eax
801046bb:	25 ff 0f 00 00       	and    $0xfff,%eax
801046c0:	85 c0                	test   %eax,%eax
801046c2:	75 0c                	jne    801046d0 <register_handler+0x4d>
    panic("esp_offset == 0");
801046c4:	c7 04 24 d6 9a 10 80 	movl   $0x80109ad6,(%esp)
801046cb:	e8 6d be ff ff       	call   8010053d <panic>

    /* open a new frame */
  *(int*)(addr + ((proc->tf->esp - 4) & 0xFFF))
801046d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d6:	8b 40 18             	mov    0x18(%eax),%eax
801046d9:	8b 40 44             	mov    0x44(%eax),%eax
801046dc:	83 e8 04             	sub    $0x4,%eax
801046df:	25 ff 0f 00 00       	and    $0xfff,%eax
801046e4:	03 45 f4             	add    -0xc(%ebp),%eax
          = proc->tf->eip;
801046e7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046ee:	8b 52 18             	mov    0x18(%edx),%edx
801046f1:	8b 52 38             	mov    0x38(%edx),%edx
801046f4:	89 10                	mov    %edx,(%eax)
  proc->tf->esp -= 4;
801046f6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fc:	8b 40 18             	mov    0x18(%eax),%eax
801046ff:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104706:	8b 52 18             	mov    0x18(%edx),%edx
80104709:	8b 52 44             	mov    0x44(%edx),%edx
8010470c:	83 ea 04             	sub    $0x4,%edx
8010470f:	89 50 44             	mov    %edx,0x44(%eax)

    /* update eip */
  proc->tf->eip = (uint)sighandler;
80104712:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104718:	8b 40 18             	mov    0x18(%eax),%eax
8010471b:	8b 55 08             	mov    0x8(%ebp),%edx
8010471e:	89 50 38             	mov    %edx,0x38(%eax)
}
80104721:	c9                   	leave  
80104722:	c3                   	ret    

80104723 <find_inswapper>:


struct proc* find_inswapper(){
80104723:	55                   	push   %ebp
80104724:	89 e5                	mov    %esp,%ebp
80104726:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104729:	c7 45 f4 f4 4f 14 80 	movl   $0x80144ff4,-0xc(%ebp)
80104730:	eb 2e                	jmp    80104760 <find_inswapper+0x3d>
    if(strncmp(p->name,"inSwapper",9) == 0) //found inSwapper
80104732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104735:	83 c0 6c             	add    $0x6c,%eax
80104738:	c7 44 24 08 09 00 00 	movl   $0x9,0x8(%esp)
8010473f:	00 
80104740:	c7 44 24 04 b3 9a 10 	movl   $0x80109ab3,0x4(%esp)
80104747:	80 
80104748:	89 04 24             	mov    %eax,(%esp)
8010474b:	e8 8d 1c 00 00       	call   801063dd <strncmp>
80104750:	85 c0                	test   %eax,%eax
80104752:	75 05                	jne    80104759 <find_inswapper+0x36>
      return p;
80104754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104757:	eb 21                	jmp    8010477a <find_inswapper+0x57>


struct proc* find_inswapper(){
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104759:	81 45 f4 88 10 00 00 	addl   $0x1088,-0xc(%ebp)
80104760:	81 7d f4 f4 71 18 80 	cmpl   $0x801871f4,-0xc(%ebp)
80104767:	72 c9                	jb     80104732 <find_inswapper+0xf>
    if(strncmp(p->name,"inSwapper",9) == 0) //found inSwapper
      return p;
  }
  cprintf("unable to find inSwapper\n");
80104769:	c7 04 24 e6 9a 10 80 	movl   $0x80109ae6,(%esp)
80104770:	e8 2c bc ff ff       	call   801003a1 <cprintf>
  return 0;
80104775:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010477a:	c9                   	leave  
8010477b:	c3                   	ret    

8010477c <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
8010477c:	55                   	push   %ebp
8010477d:	89 e5                	mov    %esp,%ebp
8010477f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104782:	e8 68 f8 ff ff       	call   80103fef <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104787:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
8010478e:	e8 70 18 00 00       	call   80106003 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104793:	c7 45 f4 f4 4f 14 80 	movl   $0x80144ff4,-0xc(%ebp)
8010479a:	e9 8c 00 00 00       	jmp    8010482b <scheduler+0xaf>
      
      
      //wake up inswapper
      if(p->state == RUNNABLE_SUSPENDED && p->swapped){
8010479f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a2:	8b 40 0c             	mov    0xc(%eax),%eax
801047a5:	83 f8 07             	cmp    $0x7,%eax
801047a8:	75 1f                	jne    801047c9 <scheduler+0x4d>
801047aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ad:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801047b3:	85 c0                	test   %eax,%eax
801047b5:	74 12                	je     801047c9 <scheduler+0x4d>
	p = find_inswapper(); //change p to inswapper 
801047b7:	e8 67 ff ff ff       	call   80104723 <find_inswapper>
801047bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	p->state = RUNNABLE;  //wakeup inswapper
801047bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      }
      
      if(p->state != RUNNABLE)
801047c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047cc:	8b 40 0c             	mov    0xc(%eax),%eax
801047cf:	83 f8 03             	cmp    $0x3,%eax
801047d2:	75 4f                	jne    80104823 <scheduler+0xa7>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
	
      proc = p;
801047d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d7:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
801047dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e0:	89 04 24             	mov    %eax,(%esp)
801047e3:	e8 7e 48 00 00       	call   80109066 <switchuvm>
      p->state = RUNNING;
801047e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047eb:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
801047f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f8:	8b 40 1c             	mov    0x1c(%eax),%eax
801047fb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104802:	83 c2 04             	add    $0x4,%edx
80104805:	89 44 24 04          	mov    %eax,0x4(%esp)
80104809:	89 14 24             	mov    %edx,(%esp)
8010480c:	e8 fb 1c 00 00       	call   8010650c <swtch>
      switchkvm();
80104811:	e8 33 48 00 00       	call   80109049 <switchkvm>
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104816:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
8010481d:	00 00 00 00 
80104821:	eb 01                	jmp    80104824 <scheduler+0xa8>
	p = find_inswapper(); //change p to inswapper 
	p->state = RUNNABLE;  //wakeup inswapper
      }
      
      if(p->state != RUNNABLE)
        continue;
80104823:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104824:	81 45 f4 88 10 00 00 	addl   $0x1088,-0xc(%ebp)
8010482b:	81 7d f4 f4 71 18 80 	cmpl   $0x801871f4,-0xc(%ebp)
80104832:	0f 82 67 ff ff ff    	jb     8010479f <scheduler+0x23>
      switchkvm();
      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104838:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
8010483f:	e8 37 18 00 00       	call   8010607b <release>

  }
80104844:	e9 39 ff ff ff       	jmp    80104782 <scheduler+0x6>

80104849 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104849:	55                   	push   %ebp
8010484a:	89 e5                	mov    %esp,%ebp
8010484c:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
8010484f:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104856:	e8 dc 18 00 00       	call   80106137 <holding>
8010485b:	85 c0                	test   %eax,%eax
8010485d:	75 0c                	jne    8010486b <sched+0x22>
    panic("sched ptable.lock");
8010485f:	c7 04 24 00 9b 10 80 	movl   $0x80109b00,(%esp)
80104866:	e8 d2 bc ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
8010486b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104871:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104877:	83 f8 01             	cmp    $0x1,%eax
8010487a:	74 0c                	je     80104888 <sched+0x3f>
    panic("sched locks");
8010487c:	c7 04 24 12 9b 10 80 	movl   $0x80109b12,(%esp)
80104883:	e8 b5 bc ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104888:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488e:	8b 40 0c             	mov    0xc(%eax),%eax
80104891:	83 f8 04             	cmp    $0x4,%eax
80104894:	75 0c                	jne    801048a2 <sched+0x59>
    panic("sched running");
80104896:	c7 04 24 1e 9b 10 80 	movl   $0x80109b1e,(%esp)
8010489d:	e8 9b bc ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
801048a2:	e8 33 f7 ff ff       	call   80103fda <readeflags>
801048a7:	25 00 02 00 00       	and    $0x200,%eax
801048ac:	85 c0                	test   %eax,%eax
801048ae:	74 0c                	je     801048bc <sched+0x73>
    panic("sched interruptible");
801048b0:	c7 04 24 2c 9b 10 80 	movl   $0x80109b2c,(%esp)
801048b7:	e8 81 bc ff ff       	call   8010053d <panic>
  intena = cpu->intena;
801048bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801048c2:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801048c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
801048cb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801048d1:	8b 40 04             	mov    0x4(%eax),%eax
801048d4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048db:	83 c2 1c             	add    $0x1c,%edx
801048de:	89 44 24 04          	mov    %eax,0x4(%esp)
801048e2:	89 14 24             	mov    %edx,(%esp)
801048e5:	e8 22 1c 00 00       	call   8010650c <swtch>
  cpu->intena = intena;
801048ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801048f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048f3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801048f9:	c9                   	leave  
801048fa:	c3                   	ret    

801048fb <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801048fb:	55                   	push   %ebp
801048fc:	89 e5                	mov    %esp,%ebp
801048fe:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104901:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104908:	e8 f6 16 00 00       	call   80106003 <acquire>
  proc->state = RUNNABLE;
8010490d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104913:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010491a:	e8 2a ff ff ff       	call   80104849 <sched>
  release(&ptable.lock);
8010491f:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104926:	e8 50 17 00 00       	call   8010607b <release>
}
8010492b:	c9                   	leave  
8010492c:	c3                   	ret    

8010492d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010492d:	55                   	push   %ebp
8010492e:	89 e5                	mov    %esp,%ebp
80104930:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104933:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
8010493a:	e8 3c 17 00 00       	call   8010607b <release>

  if (first) {
8010493f:	a1 60 d0 10 80       	mov    0x8010d060,%eax
80104944:	85 c0                	test   %eax,%eax
80104946:	74 0f                	je     80104957 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104948:	c7 05 60 d0 10 80 00 	movl   $0x0,0x8010d060
8010494f:	00 00 00 
    initlog();
80104952:	e8 b9 e6 ff ff       	call   80103010 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104957:	c9                   	leave  
80104958:	c3                   	ret    

80104959 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104959:	55                   	push   %ebp
8010495a:	89 e5                	mov    %esp,%ebp
8010495c:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
8010495f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104965:	85 c0                	test   %eax,%eax
80104967:	75 0c                	jne    80104975 <sleep+0x1c>
    panic("sleep");
80104969:	c7 04 24 40 9b 10 80 	movl   $0x80109b40,(%esp)
80104970:	e8 c8 bb ff ff       	call   8010053d <panic>

  if(lk == 0)
80104975:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104979:	75 0c                	jne    80104987 <sleep+0x2e>
    panic("sleep without lk");
8010497b:	c7 04 24 46 9b 10 80 	movl   $0x80109b46,(%esp)
80104982:	e8 b6 bb ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104987:	81 7d 0c c0 4f 14 80 	cmpl   $0x80144fc0,0xc(%ebp)
8010498e:	74 17                	je     801049a7 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104990:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104997:	e8 67 16 00 00       	call   80106003 <acquire>
    release(lk);
8010499c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010499f:	89 04 24             	mov    %eax,(%esp)
801049a2:	e8 d4 16 00 00       	call   8010607b <release>
  }

  // Go to sleep.
  proc->chan = chan;
801049a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ad:	8b 55 08             	mov    0x8(%ebp),%edx
801049b0:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801049b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b9:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  if(proc->pid > 2 && swap_enabled){
801049c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c6:	8b 40 10             	mov    0x10(%eax),%eax
801049c9:	83 f8 02             	cmp    $0x2,%eax
801049cc:	7e 31                	jle    801049ff <sleep+0xa6>
801049ce:	a1 a8 d6 10 80       	mov    0x8010d6a8,%eax
801049d3:	85 c0                	test   %eax,%eax
801049d5:	74 28                	je     801049ff <sleep+0xa6>
    release(&ptable.lock);
801049d7:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
801049de:	e8 98 16 00 00       	call   8010607b <release>
    swapOut(proc);
801049e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e9:	89 04 24             	mov    %eax,(%esp)
801049ec:	e8 2a 0a 00 00       	call   8010541b <swapOut>
    acquire(&ptable.lock);
801049f1:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
801049f8:	e8 06 16 00 00       	call   80106003 <acquire>
801049fd:	eb 0d                	jmp    80104a0c <sleep+0xb3>
  }else{
    proc->state = SLEEPING_SUSPENDED;
801049ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a05:	c7 40 0c 06 00 00 00 	movl   $0x6,0xc(%eax)
  }
  
  sched();
80104a0c:	e8 38 fe ff ff       	call   80104849 <sched>

  // Tidy up.
  proc->chan = 0;
80104a11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a17:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104a1e:	81 7d 0c c0 4f 14 80 	cmpl   $0x80144fc0,0xc(%ebp)
80104a25:	74 17                	je     80104a3e <sleep+0xe5>
    release(&ptable.lock);
80104a27:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104a2e:	e8 48 16 00 00       	call   8010607b <release>
    acquire(lk);
80104a33:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a36:	89 04 24             	mov    %eax,(%esp)
80104a39:	e8 c5 15 00 00       	call   80106003 <acquire>
  }
}
80104a3e:	c9                   	leave  
80104a3f:	c3                   	ret    

80104a40 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104a40:	55                   	push   %ebp
80104a41:	89 e5                	mov    %esp,%ebp
80104a43:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a46:	c7 45 fc f4 4f 14 80 	movl   $0x80144ff4,-0x4(%ebp)
80104a4d:	eb 3e                	jmp    80104a8d <wakeup1+0x4d>
    if(p->state == SLEEPING_SUSPENDED && p->chan == chan){
80104a4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a52:	8b 40 0c             	mov    0xc(%eax),%eax
80104a55:	83 f8 06             	cmp    $0x6,%eax
80104a58:	75 2c                	jne    80104a86 <wakeup1+0x46>
80104a5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a5d:	8b 40 20             	mov    0x20(%eax),%eax
80104a60:	3b 45 08             	cmp    0x8(%ebp),%eax
80104a63:	75 21                	jne    80104a86 <wakeup1+0x46>
      p->state = RUNNABLE_SUSPENDED;
80104a65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a68:	c7 40 0c 07 00 00 00 	movl   $0x7,0xc(%eax)
      if(!p->swapped)
80104a6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a72:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104a78:	85 c0                	test   %eax,%eax
80104a7a:	75 0a                	jne    80104a86 <wakeup1+0x46>
	p->state = RUNNABLE;
80104a7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a7f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a86:	81 45 fc 88 10 00 00 	addl   $0x1088,-0x4(%ebp)
80104a8d:	81 7d fc f4 71 18 80 	cmpl   $0x801871f4,-0x4(%ebp)
80104a94:	72 b9                	jb     80104a4f <wakeup1+0xf>
      if(!p->swapped)
	p->state = RUNNABLE;
    }
 
  }
}
80104a96:	c9                   	leave  
80104a97:	c3                   	ret    

80104a98 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104a98:	55                   	push   %ebp
80104a99:	89 e5                	mov    %esp,%ebp
80104a9b:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104a9e:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104aa5:	e8 59 15 00 00       	call   80106003 <acquire>
  wakeup1(chan);
80104aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80104aad:	89 04 24             	mov    %eax,(%esp)
80104ab0:	e8 8b ff ff ff       	call   80104a40 <wakeup1>
  release(&ptable.lock);
80104ab5:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104abc:	e8 ba 15 00 00       	call   8010607b <release>
}
80104ac1:	c9                   	leave  
80104ac2:	c3                   	ret    

80104ac3 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ac3:	55                   	push   %ebp
80104ac4:	89 e5                	mov    %esp,%ebp
80104ac6:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ac9:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104ad0:	e8 2e 15 00 00       	call   80106003 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ad5:	c7 45 f4 f4 4f 14 80 	movl   $0x80144ff4,-0xc(%ebp)
80104adc:	eb 5b                	jmp    80104b39 <kill+0x76>
    if(p->pid == pid){
80104ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae1:	8b 40 10             	mov    0x10(%eax),%eax
80104ae4:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ae7:	75 49                	jne    80104b32 <kill+0x6f>
      p->killed = 1;
80104ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aec:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING_SUSPENDED){
80104af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af6:	8b 40 0c             	mov    0xc(%eax),%eax
80104af9:	83 f8 06             	cmp    $0x6,%eax
80104afc:	75 21                	jne    80104b1f <kill+0x5c>
        p->state = RUNNABLE_SUSPENDED;
80104afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b01:	c7 40 0c 07 00 00 00 	movl   $0x7,0xc(%eax)
	if(!p->swapped)
80104b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0b:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104b11:	85 c0                	test   %eax,%eax
80104b13:	75 0a                	jne    80104b1f <kill+0x5c>
	  p->state = RUNNABLE;
80104b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b18:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      }
      release(&ptable.lock);
80104b1f:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104b26:	e8 50 15 00 00       	call   8010607b <release>
      return 0;
80104b2b:	b8 00 00 00 00       	mov    $0x0,%eax
80104b30:	eb 21                	jmp    80104b53 <kill+0x90>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b32:	81 45 f4 88 10 00 00 	addl   $0x1088,-0xc(%ebp)
80104b39:	81 7d f4 f4 71 18 80 	cmpl   $0x801871f4,-0xc(%ebp)
80104b40:	72 9c                	jb     80104ade <kill+0x1b>
      }
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104b42:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80104b49:	e8 2d 15 00 00       	call   8010607b <release>
  return -1;
80104b4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b53:	c9                   	leave  
80104b54:	c3                   	ret    

80104b55 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b55:	55                   	push   %ebp
80104b56:	89 e5                	mov    %esp,%ebp
80104b58:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b5b:	c7 45 f0 f4 4f 14 80 	movl   $0x80144ff4,-0x10(%ebp)
80104b62:	e9 db 00 00 00       	jmp    80104c42 <procdump+0xed>
    if(p->state == UNUSED)
80104b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b6a:	8b 40 0c             	mov    0xc(%eax),%eax
80104b6d:	85 c0                	test   %eax,%eax
80104b6f:	0f 84 c5 00 00 00    	je     80104c3a <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b78:	8b 40 0c             	mov    0xc(%eax),%eax
80104b7b:	83 f8 07             	cmp    $0x7,%eax
80104b7e:	77 23                	ja     80104ba3 <procdump+0x4e>
80104b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b83:	8b 40 0c             	mov    0xc(%eax),%eax
80104b86:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80104b8d:	85 c0                	test   %eax,%eax
80104b8f:	74 12                	je     80104ba3 <procdump+0x4e>
      state = states[p->state];
80104b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b94:	8b 40 0c             	mov    0xc(%eax),%eax
80104b97:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80104b9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104ba1:	eb 07                	jmp    80104baa <procdump+0x55>
    else
      state = "???";
80104ba3:	c7 45 ec 57 9b 10 80 	movl   $0x80109b57,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bad:	8d 50 6c             	lea    0x6c(%eax),%edx
80104bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bb3:	8b 40 10             	mov    0x10(%eax),%eax
80104bb6:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104bba:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104bbd:	89 54 24 08          	mov    %edx,0x8(%esp)
80104bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bc5:	c7 04 24 5b 9b 10 80 	movl   $0x80109b5b,(%esp)
80104bcc:	e8 d0 b7 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bd4:	8b 40 0c             	mov    0xc(%eax),%eax
80104bd7:	83 f8 02             	cmp    $0x2,%eax
80104bda:	75 50                	jne    80104c2c <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bdf:	8b 40 1c             	mov    0x1c(%eax),%eax
80104be2:	8b 40 0c             	mov    0xc(%eax),%eax
80104be5:	83 c0 08             	add    $0x8,%eax
80104be8:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104beb:	89 54 24 04          	mov    %edx,0x4(%esp)
80104bef:	89 04 24             	mov    %eax,(%esp)
80104bf2:	e8 d3 14 00 00       	call   801060ca <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104bf7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bfe:	eb 1b                	jmp    80104c1b <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c03:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104c07:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c0b:	c7 04 24 64 9b 10 80 	movl   $0x80109b64,(%esp)
80104c12:	e8 8a b7 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104c17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c1b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104c1f:	7f 0b                	jg     80104c2c <procdump+0xd7>
80104c21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c24:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104c28:	85 c0                	test   %eax,%eax
80104c2a:	75 d4                	jne    80104c00 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104c2c:	c7 04 24 68 9b 10 80 	movl   $0x80109b68,(%esp)
80104c33:	e8 69 b7 ff ff       	call   801003a1 <cprintf>
80104c38:	eb 01                	jmp    80104c3b <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104c3a:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c3b:	81 45 f0 88 10 00 00 	addl   $0x1088,-0x10(%ebp)
80104c42:	81 7d f0 f4 71 18 80 	cmpl   $0x801871f4,-0x10(%ebp)
80104c49:	0f 82 18 ff ff ff    	jb     80104b67 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104c4f:	c9                   	leave  
80104c50:	c3                   	ret    

80104c51 <createInternalProcess>:

void createInternalProcess(const char *name, void (*entrypoint)()){
80104c51:	55                   	push   %ebp
80104c52:	89 e5                	mov    %esp,%ebp
80104c54:	57                   	push   %edi
80104c55:	56                   	push   %esi
80104c56:	53                   	push   %ebx
80104c57:	83 ec 2c             	sub    $0x2c,%esp
  
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104c5a:	e8 b2 f3 ff ff       	call   80104011 <allocproc>
80104c5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104c62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104c66:	75 0c                	jne    80104c74 <createInternalProcess+0x23>
    cprintf("createInternalProcess error in allocproc\n");
80104c68:	c7 04 24 6c 9b 10 80 	movl   $0x80109b6c,(%esp)
80104c6f:	e8 2d b7 ff ff       	call   801003a1 <cprintf>

   // Copy process state from p.
  if((np->pgdir = setupkvm(kalloc)) == 0)
80104c74:	c7 04 24 f3 2a 10 80 	movl   $0x80102af3,(%esp)
80104c7b:	e8 f5 42 00 00       	call   80108f75 <setupkvm>
80104c80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104c83:	89 42 04             	mov    %eax,0x4(%edx)
80104c86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104c89:	8b 40 04             	mov    0x4(%eax),%eax
80104c8c:	85 c0                	test   %eax,%eax
80104c8e:	75 0c                	jne    80104c9c <createInternalProcess+0x4b>
   cprintf("createInternalProcess error in setupkvm\n");
80104c90:	c7 04 24 98 9b 10 80 	movl   $0x80109b98,(%esp)
80104c97:	e8 05 b7 ff ff       	call   801003a1 <cprintf>
 
  memset(np->tf, 0, sizeof(*np->tf));
80104c9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104c9f:	8b 40 18             	mov    0x18(%eax),%eax
80104ca2:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104ca9:	00 
80104caa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104cb1:	00 
80104cb2:	89 04 24             	mov    %eax,(%esp)
80104cb5:	e8 ac 15 00 00       	call   80106266 <memset>
  np->tf->cs = (SEG_UCODE << 3) | 0;
80104cba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cbd:	8b 40 18             	mov    0x18(%eax),%eax
80104cc0:	66 c7 40 3c 20 00    	movw   $0x20,0x3c(%eax)
  np->tf->ds = (SEG_UDATA << 3) | 0;
80104cc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cc9:	8b 40 18             	mov    0x18(%eax),%eax
80104ccc:	66 c7 40 2c 28 00    	movw   $0x28,0x2c(%eax)
  np->tf->es = np->tf->ds;
80104cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cd5:	8b 40 18             	mov    0x18(%eax),%eax
80104cd8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104cdb:	8b 52 18             	mov    0x18(%edx),%edx
80104cde:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104ce2:	66 89 50 28          	mov    %dx,0x28(%eax)
  np->tf->ss = np->tf->ds;
80104ce6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ce9:	8b 40 18             	mov    0x18(%eax),%eax
80104cec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104cef:	8b 52 18             	mov    0x18(%edx),%edx
80104cf2:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104cf6:	66 89 50 48          	mov    %dx,0x48(%eax)
  np->tf->eflags = FL_IF;
80104cfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cfd:	8b 40 18             	mov    0x18(%eax),%eax
80104d00:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
   
   
  np->sz = initproc->sz;
80104d07:	a1 ac d6 10 80       	mov    0x8010d6ac,%eax
80104d0c:	8b 10                	mov    (%eax),%edx
80104d0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d11:	89 10                	mov    %edx,(%eax)
  np->parent = initproc;
80104d13:	8b 15 ac d6 10 80    	mov    0x8010d6ac,%edx
80104d19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d1c:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *initproc->tf;
80104d1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d22:	8b 50 18             	mov    0x18(%eax),%edx
80104d25:	a1 ac d6 10 80       	mov    0x8010d6ac,%eax
80104d2a:	8b 40 18             	mov    0x18(%eax),%eax
80104d2d:	89 c3                	mov    %eax,%ebx
80104d2f:	b8 13 00 00 00       	mov    $0x13,%eax
80104d34:	89 d7                	mov    %edx,%edi
80104d36:	89 de                	mov    %ebx,%esi
80104d38:	89 c1                	mov    %eax,%ecx
80104d3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  // Clear %eax so that fork returns 0 in the child.
  //np->tf->eax = 0;
  // Set starting point of inswapper
  //np->cwd = idup(initproc->cwd);
  np->cwd = namei("/");
80104d3c:	c7 04 24 b1 9a 10 80 	movl   $0x80109ab1,(%esp)
80104d43:	e8 c2 d6 ff ff       	call   8010240a <namei>
80104d48:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d4b:	89 42 68             	mov    %eax,0x68(%edx)
  np->context->eip = (uint)entrypoint;
80104d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d51:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d54:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d57:	89 50 10             	mov    %edx,0x10(%eax)


  
 np->state = RUNNABLE;
80104d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d5d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
 safestrcpy(np->name, name, (strlen(name) + 1));
80104d64:	8b 45 08             	mov    0x8(%ebp),%eax
80104d67:	89 04 24             	mov    %eax,(%esp)
80104d6a:	e8 75 17 00 00       	call   801064e4 <strlen>
80104d6f:	83 c0 01             	add    $0x1,%eax
80104d72:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d75:	83 c2 6c             	add    $0x6c,%edx
80104d78:	89 44 24 08          	mov    %eax,0x8(%esp)
80104d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d83:	89 14 24             	mov    %edx,(%esp)
80104d86:	e8 0b 17 00 00       	call   80106496 <safestrcpy>

}
80104d8b:	83 c4 2c             	add    $0x2c,%esp
80104d8e:	5b                   	pop    %ebx
80104d8f:	5e                   	pop    %esi
80104d90:	5f                   	pop    %edi
80104d91:	5d                   	pop    %ebp
80104d92:	c3                   	ret    

80104d93 <kernel_unlink>:

int
kernel_unlink(char* path)
{
80104d93:	55                   	push   %ebp
80104d94:	89 e5                	mov    %esp,%ebp
80104d96:	83 ec 48             	sub    $0x48,%esp
  char name[DIRSIZ];
  uint off;

//   if(argstr(0, &path) < 0)
//     return -1;
  if((dp = nameiparent(path, name)) == 0)
80104d99:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80104d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104da0:	8b 45 08             	mov    0x8(%ebp),%eax
80104da3:	89 04 24             	mov    %eax,(%esp)
80104da6:	e8 81 d6 ff ff       	call   8010242c <nameiparent>
80104dab:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104dae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104db2:	75 0a                	jne    80104dbe <kernel_unlink+0x2b>
    return -1;
80104db4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104db9:	e9 59 01 00 00       	jmp    80104f17 <kernel_unlink+0x184>

  begin_trans();
80104dbe:	e8 5a e4 ff ff       	call   8010321d <begin_trans>

  ilock(dp);
80104dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc6:	89 04 24             	mov    %eax,(%esp)
80104dc9:	e8 9a ca ff ff       	call   80101868 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104dce:	c7 44 24 04 c1 9b 10 	movl   $0x80109bc1,0x4(%esp)
80104dd5:	80 
80104dd6:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80104dd9:	89 04 24             	mov    %eax,(%esp)
80104ddc:	e8 7e d2 ff ff       	call   8010205f <namecmp>
80104de1:	85 c0                	test   %eax,%eax
80104de3:	0f 84 19 01 00 00    	je     80104f02 <kernel_unlink+0x16f>
80104de9:	c7 44 24 04 c3 9b 10 	movl   $0x80109bc3,0x4(%esp)
80104df0:	80 
80104df1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80104df4:	89 04 24             	mov    %eax,(%esp)
80104df7:	e8 63 d2 ff ff       	call   8010205f <namecmp>
80104dfc:	85 c0                	test   %eax,%eax
80104dfe:	0f 84 fe 00 00 00    	je     80104f02 <kernel_unlink+0x16f>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80104e04:	8d 45 cc             	lea    -0x34(%ebp),%eax
80104e07:	89 44 24 08          	mov    %eax,0x8(%esp)
80104e0b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80104e0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e15:	89 04 24             	mov    %eax,(%esp)
80104e18:	e8 64 d2 ff ff       	call   80102081 <dirlookup>
80104e1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104e20:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e24:	0f 84 d7 00 00 00    	je     80104f01 <kernel_unlink+0x16e>
    goto bad;
  ilock(ip);
80104e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e2d:	89 04 24             	mov    %eax,(%esp)
80104e30:	e8 33 ca ff ff       	call   80101868 <ilock>

  if(ip->nlink < 1)
80104e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e38:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80104e3c:	66 85 c0             	test   %ax,%ax
80104e3f:	7f 0c                	jg     80104e4d <kernel_unlink+0xba>
    panic("unlink: nlink < 1");
80104e41:	c7 04 24 c6 9b 10 80 	movl   $0x80109bc6,(%esp)
80104e48:	e8 f0 b6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
    goto bad;
  }
*/
  memset(&de, 0, sizeof(de));
80104e4d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104e54:	00 
80104e55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104e5c:	00 
80104e5d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104e60:	89 04 24             	mov    %eax,(%esp)
80104e63:	e8 fe 13 00 00       	call   80106266 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104e68:	8b 45 cc             	mov    -0x34(%ebp),%eax
80104e6b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80104e72:	00 
80104e73:	89 44 24 08          	mov    %eax,0x8(%esp)
80104e77:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104e7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e81:	89 04 24             	mov    %eax,(%esp)
80104e84:	e8 40 d0 ff ff       	call   80101ec9 <writei>
80104e89:	83 f8 10             	cmp    $0x10,%eax
80104e8c:	74 0c                	je     80104e9a <kernel_unlink+0x107>
    panic("unlink: writei");
80104e8e:	c7 04 24 d8 9b 10 80 	movl   $0x80109bd8,(%esp)
80104e95:	e8 a3 b6 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80104e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e9d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80104ea1:	66 83 f8 01          	cmp    $0x1,%ax
80104ea5:	75 1c                	jne    80104ec3 <kernel_unlink+0x130>
    dp->nlink--;
80104ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eaa:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80104eae:	8d 50 ff             	lea    -0x1(%eax),%edx
80104eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb4:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80104eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebb:	89 04 24             	mov    %eax,(%esp)
80104ebe:	e8 e9 c7 ff ff       	call   801016ac <iupdate>
  }
  iunlockput(dp);
80104ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec6:	89 04 24             	mov    %eax,(%esp)
80104ec9:	e8 1e cc ff ff       	call   80101aec <iunlockput>

  ip->nlink--;
80104ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80104ed5:	8d 50 ff             	lea    -0x1(%eax),%edx
80104ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104edb:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80104edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee2:	89 04 24             	mov    %eax,(%esp)
80104ee5:	e8 c2 c7 ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
80104eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eed:	89 04 24             	mov    %eax,(%esp)
80104ef0:	e8 f7 cb ff ff       	call   80101aec <iunlockput>

  commit_trans();
80104ef5:	e8 46 e3 ff ff       	call   80103240 <commit_trans>

  return 0;
80104efa:	b8 00 00 00 00       	mov    $0x0,%eax
80104eff:	eb 16                	jmp    80104f17 <kernel_unlink+0x184>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80104f01:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80104f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f05:	89 04 24             	mov    %eax,(%esp)
80104f08:	e8 df cb ff ff       	call   80101aec <iunlockput>
  commit_trans();
80104f0d:	e8 2e e3 ff ff       	call   80103240 <commit_trans>
  return -1;
80104f12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f17:	c9                   	leave  
80104f18:	c3                   	ret    

80104f19 <kernel_fdalloc>:

int
kernel_fdalloc(struct file *f)
{
80104f19:	55                   	push   %ebp
80104f1a:	89 e5                	mov    %esp,%ebp
80104f1c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80104f1f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104f26:	eb 30                	jmp    80104f58 <kernel_fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80104f28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f2e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f31:	83 c2 08             	add    $0x8,%edx
80104f34:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f38:	85 c0                	test   %eax,%eax
80104f3a:	75 18                	jne    80104f54 <kernel_fdalloc+0x3b>
      proc->ofile[fd] = f;
80104f3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f42:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f45:	8d 4a 08             	lea    0x8(%edx),%ecx
80104f48:	8b 55 08             	mov    0x8(%ebp),%edx
80104f4b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104f4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f52:	eb 0f                	jmp    80104f63 <kernel_fdalloc+0x4a>
int
kernel_fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80104f54:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104f58:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80104f5c:	7e ca                	jle    80104f28 <kernel_fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80104f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f63:	c9                   	leave  
80104f64:	c3                   	ret    

80104f65 <kernel_create>:

struct inode*
kernel_create(char *path, short type, short major, short minor)
{
80104f65:	55                   	push   %ebp
80104f66:	89 e5                	mov    %esp,%ebp
80104f68:	83 ec 48             	sub    $0x48,%esp
80104f6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104f6e:	8b 55 10             	mov    0x10(%ebp),%edx
80104f71:	8b 45 14             	mov    0x14(%ebp),%eax
80104f74:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80104f78:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80104f7c:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];
   //cprintf("nameiparent path: %s\n",path);
  if((dp = nameiparent(path, name)) == 0)
80104f80:	8d 45 de             	lea    -0x22(%ebp),%eax
80104f83:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f87:	8b 45 08             	mov    0x8(%ebp),%eax
80104f8a:	89 04 24             	mov    %eax,(%esp)
80104f8d:	e8 9a d4 ff ff       	call   8010242c <nameiparent>
80104f92:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f95:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f99:	75 0a                	jne    80104fa5 <kernel_create+0x40>
    return 0;
80104f9b:	b8 00 00 00 00       	mov    $0x0,%eax
80104fa0:	e9 7e 01 00 00       	jmp    80105123 <kernel_create+0x1be>
  
  ilock(dp);
80104fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa8:	89 04 24             	mov    %eax,(%esp)
80104fab:	e8 b8 c8 ff ff       	call   80101868 <ilock>
  
  if((ip = dirlookup(dp, name, &off)) != 0){
80104fb0:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fb3:	89 44 24 08          	mov    %eax,0x8(%esp)
80104fb7:	8d 45 de             	lea    -0x22(%ebp),%eax
80104fba:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc1:	89 04 24             	mov    %eax,(%esp)
80104fc4:	e8 b8 d0 ff ff       	call   80102081 <dirlookup>
80104fc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104fcc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104fd0:	74 47                	je     80105019 <kernel_create+0xb4>
    iunlockput(dp);
80104fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd5:	89 04 24             	mov    %eax,(%esp)
80104fd8:	e8 0f cb ff ff       	call   80101aec <iunlockput>
    ilock(ip);
80104fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fe0:	89 04 24             	mov    %eax,(%esp)
80104fe3:	e8 80 c8 ff ff       	call   80101868 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104fe8:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104fed:	75 15                	jne    80105004 <kernel_create+0x9f>
80104fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80104ff6:	66 83 f8 02          	cmp    $0x2,%ax
80104ffa:	75 08                	jne    80105004 <kernel_create+0x9f>
      return ip;
80104ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fff:	e9 1f 01 00 00       	jmp    80105123 <kernel_create+0x1be>
    iunlockput(ip);
80105004:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105007:	89 04 24             	mov    %eax,(%esp)
8010500a:	e8 dd ca ff ff       	call   80101aec <iunlockput>
    return 0;
8010500f:	b8 00 00 00 00       	mov    $0x0,%eax
80105014:	e9 0a 01 00 00       	jmp    80105123 <kernel_create+0x1be>
  }
  
  if((ip = ialloc(dp->dev, type)) == 0)
80105019:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010501d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105020:	8b 00                	mov    (%eax),%eax
80105022:	89 54 24 04          	mov    %edx,0x4(%esp)
80105026:	89 04 24             	mov    %eax,(%esp)
80105029:	e8 a1 c5 ff ff       	call   801015cf <ialloc>
8010502e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105031:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105035:	75 0c                	jne    80105043 <kernel_create+0xde>
    panic("create: ialloc");
80105037:	c7 04 24 e7 9b 10 80 	movl   $0x80109be7,(%esp)
8010503e:	e8 fa b4 ff ff       	call   8010053d <panic>

  ilock(ip);
80105043:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105046:	89 04 24             	mov    %eax,(%esp)
80105049:	e8 1a c8 ff ff       	call   80101868 <ilock>
  ip->major = major;
8010504e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105051:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105055:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105059:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010505c:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105060:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105064:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105067:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
8010506d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105070:	89 04 24             	mov    %eax,(%esp)
80105073:	e8 34 c6 ff ff       	call   801016ac <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80105078:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010507d:	75 6a                	jne    801050e9 <kernel_create+0x184>
    dp->nlink++;  // for ".."
8010507f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105082:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105086:	8d 50 01             	lea    0x1(%eax),%edx
80105089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010508c:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105093:	89 04 24             	mov    %eax,(%esp)
80105096:	e8 11 c6 ff ff       	call   801016ac <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010509b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010509e:	8b 40 04             	mov    0x4(%eax),%eax
801050a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801050a5:	c7 44 24 04 c1 9b 10 	movl   $0x80109bc1,0x4(%esp)
801050ac:	80 
801050ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050b0:	89 04 24             	mov    %eax,(%esp)
801050b3:	e8 91 d0 ff ff       	call   80102149 <dirlink>
801050b8:	85 c0                	test   %eax,%eax
801050ba:	78 21                	js     801050dd <kernel_create+0x178>
801050bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050bf:	8b 40 04             	mov    0x4(%eax),%eax
801050c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801050c6:	c7 44 24 04 c3 9b 10 	movl   $0x80109bc3,0x4(%esp)
801050cd:	80 
801050ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d1:	89 04 24             	mov    %eax,(%esp)
801050d4:	e8 70 d0 ff ff       	call   80102149 <dirlink>
801050d9:	85 c0                	test   %eax,%eax
801050db:	79 0c                	jns    801050e9 <kernel_create+0x184>
      panic("create dots");
801050dd:	c7 04 24 f6 9b 10 80 	movl   $0x80109bf6,(%esp)
801050e4:	e8 54 b4 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801050e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ec:	8b 40 04             	mov    0x4(%eax),%eax
801050ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801050f3:	8d 45 de             	lea    -0x22(%ebp),%eax
801050f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801050fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050fd:	89 04 24             	mov    %eax,(%esp)
80105100:	e8 44 d0 ff ff       	call   80102149 <dirlink>
80105105:	85 c0                	test   %eax,%eax
80105107:	79 0c                	jns    80105115 <kernel_create+0x1b0>
    panic("create: dirlink");
80105109:	c7 04 24 02 9c 10 80 	movl   $0x80109c02,(%esp)
80105110:	e8 28 b4 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80105115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105118:	89 04 24             	mov    %eax,(%esp)
8010511b:	e8 cc c9 ff ff       	call   80101aec <iunlockput>
  return ip;
80105120:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105123:	c9                   	leave  
80105124:	c3                   	ret    

80105125 <kernel_open>:

struct file* kernel_open(char* path, int omode){
80105125:	55                   	push   %ebp
80105126:	89 e5                	mov    %esp,%ebp
80105128:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  struct inode *ip;
  if(omode & O_CREATE){
8010512b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010512e:	25 00 02 00 00       	and    $0x200,%eax
80105133:	85 c0                	test   %eax,%eax
80105135:	74 40                	je     80105177 <kernel_open+0x52>
    begin_trans();
80105137:	e8 e1 e0 ff ff       	call   8010321d <begin_trans>
    ip = kernel_create(path, T_FILE, 0, 0);
8010513c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105143:	00 
80105144:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010514b:	00 
8010514c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105153:	00 
80105154:	8b 45 08             	mov    0x8(%ebp),%eax
80105157:	89 04 24             	mov    %eax,(%esp)
8010515a:	e8 06 fe ff ff       	call   80104f65 <kernel_create>
8010515f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105162:	e8 d9 e0 ff ff       	call   80103240 <commit_trans>
    if(ip == 0)
80105167:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010516b:	75 5b                	jne    801051c8 <kernel_open+0xa3>
      return 0;
8010516d:	b8 00 00 00 00       	mov    $0x0,%eax
80105172:	e9 f9 00 00 00       	jmp    80105270 <kernel_open+0x14b>
  } else {
//     cprintf("kernel_open - path is %s\n",path);
    if((ip = namei(path)) == 0)
80105177:	8b 45 08             	mov    0x8(%ebp),%eax
8010517a:	89 04 24             	mov    %eax,(%esp)
8010517d:	e8 88 d2 ff ff       	call   8010240a <namei>
80105182:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105185:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105189:	75 0a                	jne    80105195 <kernel_open+0x70>
      return 0;
8010518b:	b8 00 00 00 00       	mov    $0x0,%eax
80105190:	e9 db 00 00 00       	jmp    80105270 <kernel_open+0x14b>
    //cprintf("kernel_open - path is %s passed namei\n",path);
    ilock(ip);
80105195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105198:	89 04 24             	mov    %eax,(%esp)
8010519b:	e8 c8 c6 ff ff       	call   80101868 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801051a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051a3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801051a7:	66 83 f8 01          	cmp    $0x1,%ax
801051ab:	75 1b                	jne    801051c8 <kernel_open+0xa3>
801051ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801051b1:	74 15                	je     801051c8 <kernel_open+0xa3>
      iunlockput(ip);
801051b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b6:	89 04 24             	mov    %eax,(%esp)
801051b9:	e8 2e c9 ff ff       	call   80101aec <iunlockput>
      return 0;
801051be:	b8 00 00 00 00       	mov    $0x0,%eax
801051c3:	e9 a8 00 00 00       	jmp    80105270 <kernel_open+0x14b>
    }
  }
//   cprintf("kernel_open - before filealloc path %s\n",path);
  if((f = filealloc()) == 0 || (fd = kernel_fdalloc(f)) < 0){
801051c8:	e8 4f bd ff ff       	call   80100f1c <filealloc>
801051cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801051d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801051d4:	74 14                	je     801051ea <kernel_open+0xc5>
801051d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d9:	89 04 24             	mov    %eax,(%esp)
801051dc:	e8 38 fd ff ff       	call   80104f19 <kernel_fdalloc>
801051e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801051e4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801051e8:	79 23                	jns    8010520d <kernel_open+0xe8>
    if(f)
801051ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801051ee:	74 0b                	je     801051fb <kernel_open+0xd6>
      fileclose(f);
801051f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f3:	89 04 24             	mov    %eax,(%esp)
801051f6:	e8 c9 bd ff ff       	call   80100fc4 <fileclose>
    iunlockput(ip);
801051fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fe:	89 04 24             	mov    %eax,(%esp)
80105201:	e8 e6 c8 ff ff       	call   80101aec <iunlockput>
    return 0;
80105206:	b8 00 00 00 00       	mov    $0x0,%eax
8010520b:	eb 63                	jmp    80105270 <kernel_open+0x14b>
  }
  iunlock(ip);
8010520d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105210:	89 04 24             	mov    %eax,(%esp)
80105213:	e8 9e c7 ff ff       	call   801019b6 <iunlock>

  f->type = FD_INODE;
80105218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521b:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105221:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105224:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105227:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010522a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010522d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105234:	8b 45 0c             	mov    0xc(%ebp),%eax
80105237:	83 e0 01             	and    $0x1,%eax
8010523a:	85 c0                	test   %eax,%eax
8010523c:	0f 94 c2             	sete   %dl
8010523f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105242:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105245:	8b 45 0c             	mov    0xc(%ebp),%eax
80105248:	83 e0 01             	and    $0x1,%eax
8010524b:	84 c0                	test   %al,%al
8010524d:	75 0a                	jne    80105259 <kernel_open+0x134>
8010524f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105252:	83 e0 02             	and    $0x2,%eax
80105255:	85 c0                	test   %eax,%eax
80105257:	74 07                	je     80105260 <kernel_open+0x13b>
80105259:	b8 01 00 00 00       	mov    $0x1,%eax
8010525e:	eb 05                	jmp    80105265 <kernel_open+0x140>
80105260:	b8 00 00 00 00       	mov    $0x0,%eax
80105265:	89 c2                	mov    %eax,%edx
80105267:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010526a:	88 50 09             	mov    %dl,0x9(%eax)
  return f;
8010526d:	8b 45 f0             	mov    -0x10(%ebp),%eax
//return fd;
  //return 0;
}
80105270:	c9                   	leave  
80105271:	c3                   	ret    

80105272 <reverse>:

void reverse(char* str, int length){
80105272:	55                   	push   %ebp
80105273:	89 e5                	mov    %esp,%ebp
80105275:	83 ec 10             	sub    $0x10,%esp
    int i = 0, j = length-1;
80105278:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010527f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105282:	83 e8 01             	sub    $0x1,%eax
80105285:	89 45 f8             	mov    %eax,-0x8(%ebp)
    char tmp;
    while (i < j) {
80105288:	eb 31                	jmp    801052bb <reverse+0x49>
        tmp = str[i];
8010528a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010528d:	03 45 08             	add    0x8(%ebp),%eax
80105290:	0f b6 00             	movzbl (%eax),%eax
80105293:	88 45 f7             	mov    %al,-0x9(%ebp)
        str[i] = str[j];
80105296:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105299:	03 45 08             	add    0x8(%ebp),%eax
8010529c:	8b 55 f8             	mov    -0x8(%ebp),%edx
8010529f:	03 55 08             	add    0x8(%ebp),%edx
801052a2:	0f b6 12             	movzbl (%edx),%edx
801052a5:	88 10                	mov    %dl,(%eax)
        str[j] = tmp;
801052a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052aa:	03 45 08             	add    0x8(%ebp),%eax
801052ad:	0f b6 55 f7          	movzbl -0x9(%ebp),%edx
801052b1:	88 10                	mov    %dl,(%eax)
        i++; j--;
801052b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801052b7:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
}

void reverse(char* str, int length){
    int i = 0, j = length-1;
    char tmp;
    while (i < j) {
801052bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052be:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801052c1:	7c c7                	jl     8010528a <reverse+0x18>
        tmp = str[i];
        str[i] = str[j];
        str[j] = tmp;
        i++; j--;
    }
}
801052c3:	c9                   	leave  
801052c4:	c3                   	ret    

801052c5 <itoa>:

int itoa(int n, char* out)
{
801052c5:	55                   	push   %ebp
801052c6:	89 e5                	mov    %esp,%ebp
801052c8:	53                   	push   %ebx
801052c9:	83 ec 18             	sub    $0x18,%esp
    // if negative, need 1 char for the sign
    int sign = n < 0? 1: 0;
801052cc:	8b 45 08             	mov    0x8(%ebp),%eax
801052cf:	c1 e8 1f             	shr    $0x1f,%eax
801052d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int i = 0;
801052d5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
    if (n == 0) {
801052dc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801052e0:	75 0f                	jne    801052f1 <itoa+0x2c>
        out[i++] = '0';
801052e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052e5:	03 45 0c             	add    0xc(%ebp),%eax
801052e8:	c6 00 30             	movb   $0x30,(%eax)
801052eb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    } else if (n < 0) {
        out[i++] = '-';
        n = -n;
    }
    while (n > 0) {
801052ef:	eb 6b                	jmp    8010535c <itoa+0x97>
    // if negative, need 1 char for the sign
    int sign = n < 0? 1: 0;
    int i = 0;
    if (n == 0) {
        out[i++] = '0';
    } else if (n < 0) {
801052f1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801052f5:	79 65                	jns    8010535c <itoa+0x97>
        out[i++] = '-';
801052f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052fa:	03 45 0c             	add    0xc(%ebp),%eax
801052fd:	c6 00 2d             	movb   $0x2d,(%eax)
80105300:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
        n = -n;
80105304:	f7 5d 08             	negl   0x8(%ebp)
    }
    while (n > 0) {
80105307:	eb 53                	jmp    8010535c <itoa+0x97>
        out[i++] = '0' + n % 10;
80105309:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010530c:	89 c3                	mov    %eax,%ebx
8010530e:	03 5d 0c             	add    0xc(%ebp),%ebx
80105311:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105314:	ba 67 66 66 66       	mov    $0x66666667,%edx
80105319:	89 c8                	mov    %ecx,%eax
8010531b:	f7 ea                	imul   %edx
8010531d:	c1 fa 02             	sar    $0x2,%edx
80105320:	89 c8                	mov    %ecx,%eax
80105322:	c1 f8 1f             	sar    $0x1f,%eax
80105325:	29 c2                	sub    %eax,%edx
80105327:	89 d0                	mov    %edx,%eax
80105329:	c1 e0 02             	shl    $0x2,%eax
8010532c:	01 d0                	add    %edx,%eax
8010532e:	01 c0                	add    %eax,%eax
80105330:	89 ca                	mov    %ecx,%edx
80105332:	29 c2                	sub    %eax,%edx
80105334:	89 d0                	mov    %edx,%eax
80105336:	83 c0 30             	add    $0x30,%eax
80105339:	88 03                	mov    %al,(%ebx)
8010533b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
        n /= 10;
8010533f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105342:	ba 67 66 66 66       	mov    $0x66666667,%edx
80105347:	89 c8                	mov    %ecx,%eax
80105349:	f7 ea                	imul   %edx
8010534b:	c1 fa 02             	sar    $0x2,%edx
8010534e:	89 c8                	mov    %ecx,%eax
80105350:	c1 f8 1f             	sar    $0x1f,%eax
80105353:	89 d1                	mov    %edx,%ecx
80105355:	29 c1                	sub    %eax,%ecx
80105357:	89 c8                	mov    %ecx,%eax
80105359:	89 45 08             	mov    %eax,0x8(%ebp)
        out[i++] = '0';
    } else if (n < 0) {
        out[i++] = '-';
        n = -n;
    }
    while (n > 0) {
8010535c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105360:	7f a7                	jg     80105309 <itoa+0x44>
        out[i++] = '0' + n % 10;
        n /= 10;
    }
    out[i] = '\0';
80105362:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105365:	03 45 0c             	add    0xc(%ebp),%eax
80105368:	c6 00 00             	movb   $0x0,(%eax)
    reverse(out + sign, i - sign);
8010536b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010536e:	8b 55 f8             	mov    -0x8(%ebp),%edx
80105371:	29 c2                	sub    %eax,%edx
80105373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105376:	03 45 0c             	add    0xc(%ebp),%eax
80105379:	89 54 24 04          	mov    %edx,0x4(%esp)
8010537d:	89 04 24             	mov    %eax,(%esp)
80105380:	e8 ed fe ff ff       	call   80105272 <reverse>
    return 0;
80105385:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010538a:	83 c4 18             	add    $0x18,%esp
8010538d:	5b                   	pop    %ebx
8010538e:	5d                   	pop    %ebp
8010538f:	c3                   	ret    

80105390 <strcat>:

void strcat(char* ans,int j,char* first, char* second){
80105390:	55                   	push   %ebp
80105391:	89 e5                	mov    %esp,%ebp
80105393:	53                   	push   %ebx
80105394:	83 ec 24             	sub    $0x24,%esp
   int length1 = strlen(first);
80105397:	8b 45 10             	mov    0x10(%ebp),%eax
8010539a:	89 04 24             	mov    %eax,(%esp)
8010539d:	e8 42 11 00 00       	call   801064e4 <strlen>
801053a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
   int length2 = strlen(second);
801053a5:	8b 45 14             	mov    0x14(%ebp),%eax
801053a8:	89 04 24             	mov    %eax,(%esp)
801053ab:	e8 34 11 00 00       	call   801064e4 <strlen>
801053b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
   int length =length1 + length2+j;
801053b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801053b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053b9:	01 d0                	add    %edx,%eax
801053bb:	03 45 0c             	add    0xc(%ebp),%eax
801053be:	89 45 e8             	mov    %eax,-0x18(%ebp)
   //cprintf("first %s length1 %d\n",first,length1);
   //cprintf("second %s length2 %d\n",second,length2);
   int i = 0;
801053c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
   while(i < length){
801053c8:	eb 43                	jmp    8010540d <strcat+0x7d>
     //cprintf("ans %s i %d j %d\n",ans,i,j);
     if(i < length1){
801053ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053cd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801053d0:	7d 18                	jge    801053ea <strcat+0x5a>
      ans[i+j] = first[i];
801053d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053d8:	01 d0                	add    %edx,%eax
801053da:	03 45 08             	add    0x8(%ebp),%eax
801053dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053e0:	03 55 10             	add    0x10(%ebp),%edx
801053e3:	0f b6 12             	movzbl (%edx),%edx
801053e6:	88 10                	mov    %dl,(%eax)
801053e8:	eb 1f                	jmp    80105409 <strcat+0x79>
     }else{
      ans[i+j] = second[i - length1]; 
801053ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053f0:	01 d0                	add    %edx,%eax
801053f2:	03 45 08             	add    0x8(%ebp),%eax
801053f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053f8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801053fb:	89 cb                	mov    %ecx,%ebx
801053fd:	29 d3                	sub    %edx,%ebx
801053ff:	89 da                	mov    %ebx,%edx
80105401:	03 55 14             	add    0x14(%ebp),%edx
80105404:	0f b6 12             	movzbl (%edx),%edx
80105407:	88 10                	mov    %dl,(%eax)
     }
     i++;
80105409:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
   int length2 = strlen(second);
   int length =length1 + length2+j;
   //cprintf("first %s length1 %d\n",first,length1);
   //cprintf("second %s length2 %d\n",second,length2);
   int i = 0;
   while(i < length){
8010540d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105410:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80105413:	7c b5                	jl     801053ca <strcat+0x3a>
      ans[i+j] = second[i - length1]; 
     }
     i++;
   }
   //cprintf("final ans %s\n",ans);
}
80105415:	83 c4 24             	add    $0x24,%esp
80105418:	5b                   	pop    %ebx
80105419:	5d                   	pop    %ebp
8010541a:	c3                   	ret    

8010541b <swapOut>:



void swapOut(struct proc* p){
8010541b:	55                   	push   %ebp
8010541c:	89 e5                	mov    %esp,%ebp
8010541e:	53                   	push   %ebx
8010541f:	83 ec 44             	sub    $0x44,%esp
80105422:	89 e0                	mov    %esp,%eax
80105424:	89 c3                	mov    %eax,%ebx
  //create flie
  char id_as_str[3]; // need to pre determine number of digits in p->pid
  itoa(p->pid,id_as_str);
80105426:	8b 45 08             	mov    0x8(%ebp),%eax
80105429:	8b 40 10             	mov    0x10(%eax),%eax
8010542c:	8d 55 dd             	lea    -0x23(%ebp),%edx
8010542f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105433:	89 04 24             	mov    %eax,(%esp)
80105436:	e8 8a fe ff ff       	call   801052c5 <itoa>
  char path[strlen(id_as_str) + 5];
8010543b:	8d 45 dd             	lea    -0x23(%ebp),%eax
8010543e:	89 04 24             	mov    %eax,(%esp)
80105441:	e8 9e 10 00 00       	call   801064e4 <strlen>
80105446:	83 c0 05             	add    $0x5,%eax
80105449:	8d 50 ff             	lea    -0x1(%eax),%edx
8010544c:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010544f:	8d 50 0f             	lea    0xf(%eax),%edx
80105452:	b8 10 00 00 00       	mov    $0x10,%eax
80105457:	83 e8 01             	sub    $0x1,%eax
8010545a:	01 d0                	add    %edx,%eax
8010545c:	c7 45 d4 10 00 00 00 	movl   $0x10,-0x2c(%ebp)
80105463:	ba 00 00 00 00       	mov    $0x0,%edx
80105468:	f7 75 d4             	divl   -0x2c(%ebp)
8010546b:	6b c0 10             	imul   $0x10,%eax,%eax
8010546e:	29 c4                	sub    %eax,%esp
80105470:	8d 44 24 10          	lea    0x10(%esp),%eax
80105474:	83 c0 0f             	add    $0xf,%eax
80105477:	c1 e8 04             	shr    $0x4,%eax
8010547a:	c1 e0 04             	shl    $0x4,%eax
8010547d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  strcat(path,0,id_as_str,".swap");
80105480:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105483:	c7 44 24 0c 12 9c 10 	movl   $0x80109c12,0xc(%esp)
8010548a:	80 
8010548b:	8d 55 dd             	lea    -0x23(%ebp),%edx
8010548e:	89 54 24 08          	mov    %edx,0x8(%esp)
80105492:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105499:	00 
8010549a:	89 04 24             	mov    %eax,(%esp)
8010549d:	e8 ee fe ff ff       	call   80105390 <strcat>
  p->swapped_file = kernel_open(path,O_CREATE | O_WRONLY);
801054a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801054a5:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
801054ac:	00 
801054ad:	89 04 24             	mov    %eax,(%esp)
801054b0:	e8 70 fc ff ff       	call   80105125 <kernel_open>
801054b5:	8b 55 08             	mov    0x8(%ebp),%edx
801054b8:	89 42 7c             	mov    %eax,0x7c(%edx)
  
  pte_t *pte;
  int i;
  uint pa;
  for(i = 0; i < p->sz; i += PGSIZE){
801054bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801054c2:	e9 93 00 00 00       	jmp    8010555a <swapOut+0x13f>
    if((pte = walkpgdir(p->pgdir, (void *) i, 0)) == 0)
801054c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054ca:	8b 45 08             	mov    0x8(%ebp),%eax
801054cd:	8b 40 04             	mov    0x4(%eax),%eax
801054d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801054d7:	00 
801054d8:	89 54 24 04          	mov    %edx,0x4(%esp)
801054dc:	89 04 24             	mov    %eax,(%esp)
801054df:	e8 67 39 00 00       	call   80108e4b <walkpgdir>
801054e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801054e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801054eb:	75 0c                	jne    801054f9 <swapOut+0xde>
      panic("copyuvm: pte should exist");
801054ed:	c7 04 24 18 9c 10 80 	movl   $0x80109c18,(%esp)
801054f4:	e8 44 b0 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801054f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801054fc:	8b 00                	mov    (%eax),%eax
801054fe:	83 e0 01             	and    $0x1,%eax
80105501:	85 c0                	test   %eax,%eax
80105503:	75 0c                	jne    80105511 <swapOut+0xf6>
      panic("copyuvm: page not present");
80105505:	c7 04 24 32 9c 10 80 	movl   $0x80109c32,(%esp)
8010550c:	e8 2c b0 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80105511:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105514:	8b 00                	mov    (%eax),%eax
80105516:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010551b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    //cprintf("p->swapped_file %d\n",p->swapped_file);
    if(filewrite(p->swapped_file,p2v(pa),PGSIZE) < 0)
8010551e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105521:	89 04 24             	mov    %eax,(%esp)
80105524:	e8 a4 ea ff ff       	call   80103fcd <p2v>
80105529:	8b 55 08             	mov    0x8(%ebp),%edx
8010552c:	8b 52 7c             	mov    0x7c(%edx),%edx
8010552f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105536:	00 
80105537:	89 44 24 04          	mov    %eax,0x4(%esp)
8010553b:	89 14 24             	mov    %edx,(%esp)
8010553e:	e8 62 bc ff ff       	call   801011a5 <filewrite>
80105543:	85 c0                	test   %eax,%eax
80105545:	79 0c                	jns    80105553 <swapOut+0x138>
      panic("filewrite: error in swapOut");
80105547:	c7 04 24 4c 9c 10 80 	movl   $0x80109c4c,(%esp)
8010554e:	e8 ea af ff ff       	call   8010053d <panic>
  p->swapped_file = kernel_open(path,O_CREATE | O_WRONLY);
  
  pte_t *pte;
  int i;
  uint pa;
  for(i = 0; i < p->sz; i += PGSIZE){
80105553:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010555a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010555d:	8b 45 08             	mov    0x8(%ebp),%eax
80105560:	8b 00                	mov    (%eax),%eax
80105562:	39 c2                	cmp    %eax,%edx
80105564:	0f 82 5d ff ff ff    	jb     801054c7 <swapOut+0xac>
    if(filewrite(p->swapped_file,p2v(pa),PGSIZE) < 0)
      panic("filewrite: error in swapOut");
  }
      
  int fd;
  for(fd = 0; fd < NOFILE; fd++){
8010556a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105571:	eb 54                	jmp    801055c7 <swapOut+0x1ac>
    if(p->ofile[fd] && p->ofile[fd] == p->swapped_file){
80105573:	8b 45 08             	mov    0x8(%ebp),%eax
80105576:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105579:	83 c2 08             	add    $0x8,%edx
8010557c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105580:	85 c0                	test   %eax,%eax
80105582:	74 3f                	je     801055c3 <swapOut+0x1a8>
80105584:	8b 45 08             	mov    0x8(%ebp),%eax
80105587:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010558a:	83 c2 08             	add    $0x8,%edx
8010558d:	8b 54 90 08          	mov    0x8(%eax,%edx,4),%edx
80105591:	8b 45 08             	mov    0x8(%ebp),%eax
80105594:	8b 40 7c             	mov    0x7c(%eax),%eax
80105597:	39 c2                	cmp    %eax,%edx
80105599:	75 28                	jne    801055c3 <swapOut+0x1a8>
     fileclose(p->ofile[fd]);
8010559b:	8b 45 08             	mov    0x8(%ebp),%eax
8010559e:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055a1:	83 c2 08             	add    $0x8,%edx
801055a4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801055a8:	89 04 24             	mov    %eax,(%esp)
801055ab:	e8 14 ba ff ff       	call   80100fc4 <fileclose>
     p->ofile[fd] = 0;
801055b0:	8b 45 08             	mov    0x8(%ebp),%eax
801055b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055b6:	83 c2 08             	add    $0x8,%edx
801055b9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801055c0:	00 
     break;
801055c1:	eb 0a                	jmp    801055cd <swapOut+0x1b2>
    if(filewrite(p->swapped_file,p2v(pa),PGSIZE) < 0)
      panic("filewrite: error in swapOut");
  }
      
  int fd;
  for(fd = 0; fd < NOFILE; fd++){
801055c3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801055c7:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801055cb:	7e a6                	jle    80105573 <swapOut+0x158>
     fileclose(p->ofile[fd]);
     p->ofile[fd] = 0;
     break;
    }
  }
  p->swapped_file = 0;
801055cd:	8b 45 08             	mov    0x8(%ebp),%eax
801055d0:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->swapped = 1;
801055d7:	8b 45 08             	mov    0x8(%ebp),%eax
801055da:	c7 80 84 00 00 00 01 	movl   $0x1,0x84(%eax)
801055e1:	00 00 00 
  
  deallocuvm(p->pgdir,p->sz,0);
801055e4:	8b 45 08             	mov    0x8(%ebp),%eax
801055e7:	8b 10                	mov    (%eax),%edx
801055e9:	8b 45 08             	mov    0x8(%ebp),%eax
801055ec:	8b 40 04             	mov    0x4(%eax),%eax
801055ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801055f6:	00 
801055f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801055fb:	89 04 24             	mov    %eax,(%esp)
801055fe:	e8 12 3e 00 00       	call   80109415 <deallocuvm>
  p->state = SLEEPING_SUSPENDED;
80105603:	8b 45 08             	mov    0x8(%ebp),%eax
80105606:	c7 40 0c 06 00 00 00 	movl   $0x6,0xc(%eax)
8010560d:	89 dc                	mov    %ebx,%esp
  
}
8010560f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105612:	c9                   	leave  
80105613:	c3                   	ret    

80105614 <swapIn>:

void swapIn(struct proc* p){
80105614:	55                   	push   %ebp
80105615:	89 e5                	mov    %esp,%ebp
80105617:	53                   	push   %ebx
80105618:	83 ec 54             	sub    $0x54,%esp
8010561b:	89 e0                	mov    %esp,%eax
8010561d:	89 c3                	mov    %eax,%ebx
//   cprintf("swapIN\n");
  //create flie
  char id_as_str[3]; // need to pre determine number of digits in p->pid
  itoa(p->pid,id_as_str);
8010561f:	8b 45 08             	mov    0x8(%ebp),%eax
80105622:	8b 40 10             	mov    0x10(%eax),%eax
80105625:	8d 55 e5             	lea    -0x1b(%ebp),%edx
80105628:	89 54 24 04          	mov    %edx,0x4(%esp)
8010562c:	89 04 24             	mov    %eax,(%esp)
8010562f:	e8 91 fc ff ff       	call   801052c5 <itoa>
  char path[strlen(id_as_str) + 5];
80105634:	8d 45 e5             	lea    -0x1b(%ebp),%eax
80105637:	89 04 24             	mov    %eax,(%esp)
8010563a:	e8 a5 0e 00 00       	call   801064e4 <strlen>
8010563f:	83 c0 05             	add    $0x5,%eax
80105642:	8d 50 ff             	lea    -0x1(%eax),%edx
80105645:	89 55 f0             	mov    %edx,-0x10(%ebp)
80105648:	8d 50 0f             	lea    0xf(%eax),%edx
8010564b:	b8 10 00 00 00       	mov    $0x10,%eax
80105650:	83 e8 01             	sub    $0x1,%eax
80105653:	01 d0                	add    %edx,%eax
80105655:	c7 45 d4 10 00 00 00 	movl   $0x10,-0x2c(%ebp)
8010565c:	ba 00 00 00 00       	mov    $0x0,%edx
80105661:	f7 75 d4             	divl   -0x2c(%ebp)
80105664:	6b c0 10             	imul   $0x10,%eax,%eax
80105667:	29 c4                	sub    %eax,%esp
80105669:	8d 44 24 14          	lea    0x14(%esp),%eax
8010566d:	83 c0 0f             	add    $0xf,%eax
80105670:	c1 e8 04             	shr    $0x4,%eax
80105673:	c1 e0 04             	shl    $0x4,%eax
80105676:	89 45 ec             	mov    %eax,-0x14(%ebp)
  path[6] = '\0';
80105679:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010567c:	c6 40 06 00          	movb   $0x0,0x6(%eax)
//   path[0] = '/';
  strcat(path,0,id_as_str,".swap");
80105680:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105683:	c7 44 24 0c 12 9c 10 	movl   $0x80109c12,0xc(%esp)
8010568a:	80 
8010568b:	8d 55 e5             	lea    -0x1b(%ebp),%edx
8010568e:	89 54 24 08          	mov    %edx,0x8(%esp)
80105692:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105699:	00 
8010569a:	89 04 24             	mov    %eax,(%esp)
8010569d:	e8 ee fc ff ff       	call   80105390 <strcat>
  //cprintf("swapIn - passed strcat path: %s\n",path);
  release(&ptable.lock);
801056a2:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
801056a9:	e8 cd 09 00 00       	call   8010607b <release>
  int test;
  p->swapped_file = kernel_open(path,O_RDONLY);
801056ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801056b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056b8:	00 
801056b9:	89 04 24             	mov    %eax,(%esp)
801056bc:	e8 64 fa ff ff       	call   80105125 <kernel_open>
801056c1:	8b 55 08             	mov    0x8(%ebp),%edx
801056c4:	89 42 7c             	mov    %eax,0x7c(%edx)
//   p->swapped_file = p->ofile[p->swapped_file_fd];
//   cprintf("swapIn - passed open pid %d p->sz %d\n",p->pid,p->sz);
  p->pgdir = setupkvm();
801056c7:	e8 a9 38 00 00       	call   80108f75 <setupkvm>
801056cc:	8b 55 08             	mov    0x8(%ebp),%edx
801056cf:	89 42 04             	mov    %eax,0x4(%edx)
  test = allocuvm(p->pgdir,0,p->sz); //changed from KERNBASE
801056d2:	8b 45 08             	mov    0x8(%ebp),%eax
801056d5:	8b 10                	mov    (%eax),%edx
801056d7:	8b 45 08             	mov    0x8(%ebp),%eax
801056da:	8b 40 04             	mov    0x4(%eax),%eax
801056dd:	89 54 24 08          	mov    %edx,0x8(%esp)
801056e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056e8:	00 
801056e9:	89 04 24             	mov    %eax,(%esp)
801056ec:	e8 56 3c 00 00       	call   80109347 <allocuvm>
801056f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
//   cprintf("swapIn - passed allocuvm pid %d returned %d\n",p->pid,test);
//   cprintf("swapFile ip: %d\n",p->swapped_file->ip->size);
  test = loaduvm(p->pgdir,0,p->swapped_file->ip,0,p->sz);
801056f4:	8b 45 08             	mov    0x8(%ebp),%eax
801056f7:	8b 08                	mov    (%eax),%ecx
801056f9:	8b 45 08             	mov    0x8(%ebp),%eax
801056fc:	8b 40 7c             	mov    0x7c(%eax),%eax
801056ff:	8b 50 10             	mov    0x10(%eax),%edx
80105702:	8b 45 08             	mov    0x8(%ebp),%eax
80105705:	8b 40 04             	mov    0x4(%eax),%eax
80105708:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010570c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105713:	00 
80105714:	89 54 24 08          	mov    %edx,0x8(%esp)
80105718:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010571f:	00 
80105720:	89 04 24             	mov    %eax,(%esp)
80105723:	e8 30 3b 00 00       	call   80109258 <loaduvm>
80105728:	89 45 e8             	mov    %eax,-0x18(%ebp)
//   cprintf("swapIn - passed loaduvm pid %d returned %d\n",p->pid,test);
  test++;
8010572b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  int fd;
  for(fd = 0; fd < NOFILE; fd++){
8010572f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105736:	eb 54                	jmp    8010578c <swapIn+0x178>
    if(p->ofile[fd] && p->ofile[fd] == p->swapped_file){
80105738:	8b 45 08             	mov    0x8(%ebp),%eax
8010573b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010573e:	83 c2 08             	add    $0x8,%edx
80105741:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105745:	85 c0                	test   %eax,%eax
80105747:	74 3f                	je     80105788 <swapIn+0x174>
80105749:	8b 45 08             	mov    0x8(%ebp),%eax
8010574c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010574f:	83 c2 08             	add    $0x8,%edx
80105752:	8b 54 90 08          	mov    0x8(%eax,%edx,4),%edx
80105756:	8b 45 08             	mov    0x8(%ebp),%eax
80105759:	8b 40 7c             	mov    0x7c(%eax),%eax
8010575c:	39 c2                	cmp    %eax,%edx
8010575e:	75 28                	jne    80105788 <swapIn+0x174>
     fileclose(p->ofile[fd]);
80105760:	8b 45 08             	mov    0x8(%ebp),%eax
80105763:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105766:	83 c2 08             	add    $0x8,%edx
80105769:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010576d:	89 04 24             	mov    %eax,(%esp)
80105770:	e8 4f b8 ff ff       	call   80100fc4 <fileclose>
     p->ofile[fd] = 0;
80105775:	8b 45 08             	mov    0x8(%ebp),%eax
80105778:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010577b:	83 c2 08             	add    $0x8,%edx
8010577e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105785:	00 
     break;
80105786:	eb 0a                	jmp    80105792 <swapIn+0x17e>
//   cprintf("swapFile ip: %d\n",p->swapped_file->ip->size);
  test = loaduvm(p->pgdir,0,p->swapped_file->ip,0,p->sz);
//   cprintf("swapIn - passed loaduvm pid %d returned %d\n",p->pid,test);
  test++;
  int fd;
  for(fd = 0; fd < NOFILE; fd++){
80105788:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010578c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105790:	7e a6                	jle    80105738 <swapIn+0x124>
     fileclose(p->ofile[fd]);
     p->ofile[fd] = 0;
     break;
    }
  }
  p->swapped_file = 0;
80105792:	8b 45 08             	mov    0x8(%ebp),%eax
80105795:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
//   cprintf("swapIn - passed fileclose pid %d\n",p->pid);
  test = kernel_unlink(path);
8010579c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010579f:	89 04 24             	mov    %eax,(%esp)
801057a2:	e8 ec f5 ff ff       	call   80104d93 <kernel_unlink>
801057a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  //test++;
//   cprintf("swapIn - passed kernel_unlink pid %d returned %d\n",p->pid,test);
  acquire(&ptable.lock);
801057aa:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
801057b1:	e8 4d 08 00 00       	call   80106003 <acquire>
801057b6:	89 dc                	mov    %ebx,%esp
}
801057b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801057bb:	c9                   	leave  
801057bc:	c3                   	ret    

801057bd <inSwapper>:

int first = 1;
void inSwapper(){
801057bd:	55                   	push   %ebp
801057be:	89 e5                	mov    %esp,%ebp
801057c0:	83 ec 28             	sub    $0x28,%esp
  release(&ptable.lock);
801057c3:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
801057ca:	e8 ac 08 00 00       	call   8010607b <release>
  for(;;){
    struct proc *p;
    acquire(&ptable.lock);
801057cf:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
801057d6:	e8 28 08 00 00       	call   80106003 <acquire>
    //cprintf("inSwapper\n");
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801057db:	c7 45 f4 f4 4f 14 80 	movl   $0x80144ff4,-0xc(%ebp)
801057e2:	eb 41                	jmp    80105825 <inSwapper+0x68>
      if(p->state == RUNNABLE_SUSPENDED && p->swapped){
801057e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e7:	8b 40 0c             	mov    0xc(%eax),%eax
801057ea:	83 f8 07             	cmp    $0x7,%eax
801057ed:	75 2f                	jne    8010581e <inSwapper+0x61>
801057ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057f2:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801057f8:	85 c0                	test   %eax,%eax
801057fa:	74 22                	je     8010581e <inSwapper+0x61>
	//cprintf("calling swapIn process %d\n",p->pid);
	swapIn(p);
801057fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057ff:	89 04 24             	mov    %eax,(%esp)
80105802:	e8 0d fe ff ff       	call   80105614 <swapIn>
	p->swapped = 0;
80105807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580a:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80105811:	00 00 00 
	p->state = RUNNABLE;
80105814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105817:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
  for(;;){
    struct proc *p;
    acquire(&ptable.lock);
    //cprintf("inSwapper\n");
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010581e:	81 45 f4 88 10 00 00 	addl   $0x1088,-0xc(%ebp)
80105825:	81 7d f4 f4 71 18 80 	cmpl   $0x801871f4,-0xc(%ebp)
8010582c:	72 b6                	jb     801057e4 <inSwapper+0x27>
	swapIn(p);
	p->swapped = 0;
	p->state = RUNNABLE;
      }
    }
    proc->state = SLEEPING;
8010582e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105834:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
    //cprintf("inSwapper finished proc->pid %d\n",proc->pid);
    sched();
8010583b:	e8 09 f0 ff ff       	call   80104849 <sched>
    release(&ptable.lock);
80105840:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80105847:	e8 2f 08 00 00       	call   8010607b <release>
  }
8010584c:	eb 81                	jmp    801057cf <inSwapper+0x12>

8010584e <enableSwapping>:
}


int enableSwapping(){
8010584e:	55                   	push   %ebp
8010584f:	89 e5                	mov    %esp,%ebp
  swap_enabled = 1;
80105851:	c7 05 a8 d6 10 80 01 	movl   $0x1,0x8010d6a8
80105858:	00 00 00 
  return swap_enabled;
8010585b:	a1 a8 d6 10 80       	mov    0x8010d6a8,%eax
}
80105860:	5d                   	pop    %ebp
80105861:	c3                   	ret    

80105862 <disableSwapping>:
int disableSwapping(){
80105862:	55                   	push   %ebp
80105863:	89 e5                	mov    %esp,%ebp
  swap_enabled = 0;
80105865:	c7 05 a8 d6 10 80 00 	movl   $0x0,0x8010d6a8
8010586c:	00 00 00 
  return swap_enabled;
8010586f:	a1 a8 d6 10 80       	mov    0x8010d6a8,%eax
}
80105874:	5d                   	pop    %ebp
80105875:	c3                   	ret    

80105876 <num_of_pages>:
int num_of_pages(int proc_pid){
80105876:	55                   	push   %ebp
80105877:	89 e5                	mov    %esp,%ebp
80105879:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  int counter = 0;
8010587c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  acquire(&ptable.lock);
80105883:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
8010588a:	e8 74 07 00 00       	call   80106003 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010588f:	c7 45 f4 f4 4f 14 80 	movl   $0x80144ff4,-0xc(%ebp)
80105896:	e9 a8 00 00 00       	jmp    80105943 <num_of_pages+0xcd>
    if(p->pid != proc_pid)
8010589b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010589e:	8b 40 10             	mov    0x10(%eax),%eax
801058a1:	3b 45 08             	cmp    0x8(%ebp),%eax
801058a4:	74 0c                	je     801058b2 <num_of_pages+0x3c>
}
int num_of_pages(int proc_pid){
  struct proc *p;
  int counter = 0;
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801058a6:	81 45 f4 88 10 00 00 	addl   $0x1088,-0xc(%ebp)
801058ad:	e9 91 00 00 00       	jmp    80105943 <num_of_pages+0xcd>
      continue;
    int i;
    int j;
    
    pte_t *pgtab;
    for(i = 0; i < NPDENTRIES ;i++){
801058b2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
801058b9:	eb 79                	jmp    80105934 <num_of_pages+0xbe>
      if(p->pgdir[i]& PTE_P){ 
801058bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058be:	8b 40 04             	mov    0x4(%eax),%eax
801058c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058c4:	c1 e2 02             	shl    $0x2,%edx
801058c7:	01 d0                	add    %edx,%eax
801058c9:	8b 00                	mov    (%eax),%eax
801058cb:	83 e0 01             	and    $0x1,%eax
801058ce:	84 c0                	test   %al,%al
801058d0:	74 5e                	je     80105930 <num_of_pages+0xba>
	pgtab = (pte_t*)p2v(PTE_ADDR(p->pgdir[i]));
801058d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d5:	8b 40 04             	mov    0x4(%eax),%eax
801058d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058db:	c1 e2 02             	shl    $0x2,%edx
801058de:	01 d0                	add    %edx,%eax
801058e0:	8b 00                	mov    (%eax),%eax
801058e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801058e7:	89 04 24             	mov    %eax,(%esp)
801058ea:	e8 de e6 ff ff       	call   80103fcd <p2v>
801058ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(j = 0; j < NPTENTRIES; j++){
801058f2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
801058f9:	eb 2c                	jmp    80105927 <num_of_pages+0xb1>
	  if((pgtab[j] & PTE_P) && (pgtab[j] & PTE_U)){
801058fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801058fe:	c1 e0 02             	shl    $0x2,%eax
80105901:	03 45 e4             	add    -0x1c(%ebp),%eax
80105904:	8b 00                	mov    (%eax),%eax
80105906:	83 e0 01             	and    $0x1,%eax
80105909:	84 c0                	test   %al,%al
8010590b:	74 16                	je     80105923 <num_of_pages+0xad>
8010590d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105910:	c1 e0 02             	shl    $0x2,%eax
80105913:	03 45 e4             	add    -0x1c(%ebp),%eax
80105916:	8b 00                	mov    (%eax),%eax
80105918:	83 e0 04             	and    $0x4,%eax
8010591b:	85 c0                	test   %eax,%eax
8010591d:	74 04                	je     80105923 <num_of_pages+0xad>
	    counter++;
8010591f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    
    pte_t *pgtab;
    for(i = 0; i < NPDENTRIES ;i++){
      if(p->pgdir[i]& PTE_P){ 
	pgtab = (pte_t*)p2v(PTE_ADDR(p->pgdir[i]));
	for(j = 0; j < NPTENTRIES; j++){
80105923:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
80105927:	81 7d e8 ff 03 00 00 	cmpl   $0x3ff,-0x18(%ebp)
8010592e:	7e cb                	jle    801058fb <num_of_pages+0x85>
      continue;
    int i;
    int j;
    
    pte_t *pgtab;
    for(i = 0; i < NPDENTRIES ;i++){
80105930:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80105934:	81 7d ec ff 03 00 00 	cmpl   $0x3ff,-0x14(%ebp)
8010593b:	0f 8e 7a ff ff ff    	jle    801058bb <num_of_pages+0x45>
	    counter++;
	  }
	}
      }
    }
    break;
80105941:	eb 0d                	jmp    80105950 <num_of_pages+0xda>
}
int num_of_pages(int proc_pid){
  struct proc *p;
  int counter = 0;
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105943:	81 7d f4 f4 71 18 80 	cmpl   $0x801871f4,-0xc(%ebp)
8010594a:	0f 82 4b ff ff ff    	jb     8010589b <num_of_pages+0x25>
	}
      }
    }
    break;
  }
  release(&ptable.lock);
80105950:	c7 04 24 c0 4f 14 80 	movl   $0x80144fc0,(%esp)
80105957:	e8 1f 07 00 00       	call   8010607b <release>
  return counter; 
8010595c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010595f:	c9                   	leave  
80105960:	c3                   	ret    

80105961 <shmget>:

int shmget(int key, uint size, int shmflg){
80105961:	55                   	push   %ebp
80105962:	89 e5                	mov    %esp,%ebp
80105964:	83 ec 28             	sub    $0x28,%esp
  int rounded_size;
  acquire(&shmtable.lock);
80105967:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
8010596e:	e8 90 06 00 00       	call   80106003 <acquire>
  if(shmflg == GET){
80105973:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
80105977:	75 4b                	jne    801059c4 <shmget+0x63>
   if(shmtable.shmarray[key].shmstate == UNINITIALIZED){ //no shared memory object with that key
80105979:	8b 45 08             	mov    0x8(%ebp),%eax
8010597c:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105982:	05 70 20 11 80       	add    $0x80112070,%eax
80105987:	8b 40 04             	mov    0x4(%eax),%eax
8010598a:	85 c0                	test   %eax,%eax
8010598c:	75 22                	jne    801059b0 <shmget+0x4f>
    cprintf("shmget(GET)-shmarray failure\n");
8010598e:	c7 04 24 68 9c 10 80 	movl   $0x80109c68,(%esp)
80105995:	e8 07 aa ff ff       	call   801003a1 <cprintf>
    release(&shmtable.lock);
8010599a:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
801059a1:	e8 d5 06 00 00       	call   8010607b <release>
    return -1; 
801059a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059ab:	e9 69 01 00 00       	jmp    80105b19 <shmget+0x1b8>
   }else{
     release(&shmtable.lock);
801059b0:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
801059b7:	e8 bf 06 00 00       	call   8010607b <release>
     return key;
801059bc:	8b 45 08             	mov    0x8(%ebp),%eax
801059bf:	e9 55 01 00 00       	jmp    80105b19 <shmget+0x1b8>
   } 
  }
  if(shmflg == CREAT){
801059c4:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
801059c8:	0f 85 3c 01 00 00    	jne    80105b0a <shmget+0x1a9>
    if(shmtable.shmarray[key].shmstate != UNINITIALIZED){ //already created shared memory with that key
801059ce:	8b 45 08             	mov    0x8(%ebp),%eax
801059d1:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
801059d7:	05 70 20 11 80       	add    $0x80112070,%eax
801059dc:	8b 40 04             	mov    0x4(%eax),%eax
801059df:	85 c0                	test   %eax,%eax
801059e1:	74 16                	je     801059f9 <shmget+0x98>
      release(&shmtable.lock);
801059e3:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
801059ea:	e8 8c 06 00 00       	call   8010607b <release>
      return -1;
801059ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f4:	e9 20 01 00 00       	jmp    80105b19 <shmget+0x1b8>
    }
    int i = 0;
801059f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int k;
    shmtable.shmarray[key].pages_amount = 0;
80105a00:	8b 45 08             	mov    0x8(%ebp),%eax
80105a03:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105a09:	05 70 20 11 80       	add    $0x80112070,%eax
80105a0e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    shmtable.shmarray[key].key = key;
80105a15:	8b 45 08             	mov    0x8(%ebp),%eax
80105a18:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105a1e:	8d 90 e0 1f 11 80    	lea    -0x7feee020(%eax),%edx
80105a24:	8b 45 08             	mov    0x8(%ebp),%eax
80105a27:	89 42 08             	mov    %eax,0x8(%edx)
    rounded_size = PGROUNDUP(size);
80105a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a2d:	05 ff 0f 00 00       	add    $0xfff,%eax
80105a32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105a37:	89 45 ec             	mov    %eax,-0x14(%ebp)
    shmtable.shmarray[key].size = rounded_size;
80105a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105a3d:	8b 55 08             	mov    0x8(%ebp),%edx
80105a40:	69 d2 cc 00 00 00    	imul   $0xcc,%edx,%edx
80105a46:	81 c2 e0 1f 11 80    	add    $0x80111fe0,%edx
80105a4c:	89 42 0c             	mov    %eax,0xc(%edx)
    shmtable.shmarray[key].shmstate = UNLINKED;
80105a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80105a52:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105a58:	05 70 20 11 80       	add    $0x80112070,%eax
80105a5d:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
    shmtable.shmarray[key].linkcounter = 0;
80105a64:	8b 45 08             	mov    0x8(%ebp),%eax
80105a67:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105a6d:	05 70 20 11 80       	add    $0x80112070,%eax
80105a72:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    shmtable.shmarray[key].virtual_addr = 0;
80105a79:	8b 45 08             	mov    0x8(%ebp),%eax
80105a7c:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105a82:	05 60 20 11 80       	add    $0x80112060,%eax
80105a87:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
    //shmtable.shmarray[key] = newShmObj;
    for(k = 0; k < rounded_size; k+= PGSIZE){
80105a8e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105a95:	eb 6b                	jmp    80105b02 <shmget+0x1a1>
	if(!(shmtable.shmarray[key].addr[i] = kalloc())){
80105a97:	e8 57 d0 ff ff       	call   80102af3 <kalloc>
80105a9c:	8b 55 08             	mov    0x8(%ebp),%edx
80105a9f:	6b d2 33             	imul   $0x33,%edx,%edx
80105aa2:	03 55 f4             	add    -0xc(%ebp),%edx
80105aa5:	83 c2 18             	add    $0x18,%edx
80105aa8:	89 04 95 90 1f 11 80 	mov    %eax,-0x7feee070(,%edx,4)
80105aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab2:	6b c0 33             	imul   $0x33,%eax,%eax
80105ab5:	03 45 f4             	add    -0xc(%ebp),%eax
80105ab8:	83 c0 18             	add    $0x18,%eax
80105abb:	8b 04 85 90 1f 11 80 	mov    -0x7feee070(,%eax,4),%eax
80105ac2:	85 c0                	test   %eax,%eax
80105ac4:	75 0c                	jne    80105ad2 <shmget+0x171>
	  cprintf("shmget(create)-kalloc failure\n");
80105ac6:	c7 04 24 88 9c 10 80 	movl   $0x80109c88,(%esp)
80105acd:	e8 cf a8 ff ff       	call   801003a1 <cprintf>
	}
	shmtable.shmarray[key].pages_amount++;
80105ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ad5:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105adb:	05 70 20 11 80       	add    $0x80112070,%eax
80105ae0:	8b 40 08             	mov    0x8(%eax),%eax
80105ae3:	8d 50 01             	lea    0x1(%eax),%edx
80105ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ae9:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105aef:	05 70 20 11 80       	add    $0x80112070,%eax
80105af4:	89 50 08             	mov    %edx,0x8(%eax)
	i++;
80105af7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    shmtable.shmarray[key].size = rounded_size;
    shmtable.shmarray[key].shmstate = UNLINKED;
    shmtable.shmarray[key].linkcounter = 0;
    shmtable.shmarray[key].virtual_addr = 0;
    //shmtable.shmarray[key] = newShmObj;
    for(k = 0; k < rounded_size; k+= PGSIZE){
80105afb:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80105b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b05:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105b08:	7c 8d                	jl     80105a97 <shmget+0x136>
	shmtable.shmarray[key].pages_amount++;
	i++;
    }
    
  }
  release(&shmtable.lock);
80105b0a:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
80105b11:	e8 65 05 00 00       	call   8010607b <release>
  return key; 
80105b16:	8b 45 08             	mov    0x8(%ebp),%eax
  //return (int) shmtable.shmarray[key].addr[0];
}
80105b19:	c9                   	leave  
80105b1a:	c3                   	ret    

80105b1b <shmdel>:

int shmdel(int shmid){
80105b1b:	55                   	push   %ebp
80105b1c:	89 e5                	mov    %esp,%ebp
80105b1e:	83 ec 28             	sub    $0x28,%esp
  if(shmtable.shmarray[shmid].shmstate == UNLINKED && !shmtable.shmarray[shmid].linkcounter){
80105b21:	8b 45 08             	mov    0x8(%ebp),%eax
80105b24:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105b2a:	05 70 20 11 80       	add    $0x80112070,%eax
80105b2f:	8b 40 04             	mov    0x4(%eax),%eax
80105b32:	83 f8 01             	cmp    $0x1,%eax
80105b35:	0f 85 9e 00 00 00    	jne    80105bd9 <shmdel+0xbe>
80105b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b3e:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105b44:	05 70 20 11 80       	add    $0x80112070,%eax
80105b49:	8b 40 0c             	mov    0xc(%eax),%eax
80105b4c:	85 c0                	test   %eax,%eax
80105b4e:	0f 85 85 00 00 00    	jne    80105bd9 <shmdel+0xbe>
    int i;
    for(i = 0; i < shmtable.shmarray[shmid].pages_amount;i++){
80105b54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105b5b:	eb 1f                	jmp    80105b7c <shmdel+0x61>
      kfree(shmtable.shmarray[shmid].addr[i]);
80105b5d:	8b 45 08             	mov    0x8(%ebp),%eax
80105b60:	6b c0 33             	imul   $0x33,%eax,%eax
80105b63:	03 45 f4             	add    -0xc(%ebp),%eax
80105b66:	83 c0 18             	add    $0x18,%eax
80105b69:	8b 04 85 90 1f 11 80 	mov    -0x7feee070(,%eax,4),%eax
80105b70:	89 04 24             	mov    %eax,(%esp)
80105b73:	e8 e2 ce ff ff       	call   80102a5a <kfree>
}

int shmdel(int shmid){
  if(shmtable.shmarray[shmid].shmstate == UNLINKED && !shmtable.shmarray[shmid].linkcounter){
    int i;
    for(i = 0; i < shmtable.shmarray[shmid].pages_amount;i++){
80105b78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7f:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105b85:	05 70 20 11 80       	add    $0x80112070,%eax
80105b8a:	8b 40 08             	mov    0x8(%eax),%eax
80105b8d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105b90:	7f cb                	jg     80105b5d <shmdel+0x42>
      kfree(shmtable.shmarray[shmid].addr[i]);
    }
    shmtable.shmarray[shmid].pages_amount = 0;
80105b92:	8b 45 08             	mov    0x8(%ebp),%eax
80105b95:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105b9b:	05 70 20 11 80       	add    $0x80112070,%eax
80105ba0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    shmtable.shmarray[shmid].size = 0;
80105ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80105baa:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105bb0:	05 e0 1f 11 80       	add    $0x80111fe0,%eax
80105bb5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    shmtable.shmarray[shmid].shmstate = UNINITIALIZED;
80105bbc:	8b 45 08             	mov    0x8(%ebp),%eax
80105bbf:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105bc5:	05 70 20 11 80       	add    $0x80112070,%eax
80105bca:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  return key; 
  //return (int) shmtable.shmarray[key].addr[0];
}

int shmdel(int shmid){
  if(shmtable.shmarray[shmid].shmstate == UNLINKED && !shmtable.shmarray[shmid].linkcounter){
80105bd1:	90                   	nop
    shmtable.shmarray[shmid].size = 0;
    shmtable.shmarray[shmid].shmstate = UNINITIALIZED;
  }else{
   return -1; 
  }
 return 0; 
80105bd2:	b8 00 00 00 00       	mov    $0x0,%eax
80105bd7:	eb 05                	jmp    80105bde <shmdel+0xc3>
    }
    shmtable.shmarray[shmid].pages_amount = 0;
    shmtable.shmarray[shmid].size = 0;
    shmtable.shmarray[shmid].shmstate = UNINITIALIZED;
  }else{
   return -1; 
80105bd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
 return 0; 
}
80105bde:	c9                   	leave  
80105bdf:	c3                   	ret    

80105be0 <find_key>:

int find_key(const void *shmaddr ){
80105be0:	55                   	push   %ebp
80105be1:	89 e5                	mov    %esp,%ebp
80105be3:	83 ec 10             	sub    $0x10,%esp
  int ret =-1;
80105be6:	c7 45 fc ff ff ff ff 	movl   $0xffffffff,-0x4(%ebp)
  int j;
  for(j=0;j<SHM_TABLE_SIZE;j++){
80105bed:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105bf4:	eb 21                	jmp    80105c17 <find_key+0x37>
    if(proc->va[j]==shmaddr){
80105bf6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105bfc:	8b 55 f8             	mov    -0x8(%ebp),%edx
80105bff:	83 c2 20             	add    $0x20,%edx
80105c02:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c06:	3b 45 08             	cmp    0x8(%ebp),%eax
80105c09:	75 08                	jne    80105c13 <find_key+0x33>
      ret = j;
80105c0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c0e:	89 45 fc             	mov    %eax,-0x4(%ebp)
      break;
80105c11:	eb 0d                	jmp    80105c20 <find_key+0x40>
}

int find_key(const void *shmaddr ){
  int ret =-1;
  int j;
  for(j=0;j<SHM_TABLE_SIZE;j++){
80105c13:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105c17:	81 7d f8 ff 03 00 00 	cmpl   $0x3ff,-0x8(%ebp)
80105c1e:	7e d6                	jle    80105bf6 <find_key+0x16>
      ret = j;
      break;
      
    }
  }
  return ret;
80105c20:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c23:	c9                   	leave  
80105c24:	c3                   	ret    

80105c25 <shmat>:

void *shmat(int shmid, int shmflg){
80105c25:	55                   	push   %ebp
80105c26:	89 e5                	mov    %esp,%ebp
80105c28:	83 ec 48             	sub    $0x48,%esp
  char * memory;
  uint size;
  void* ret = (void*) -1;
80105c2b:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
  int i;
  int flag_for =0;
80105c32:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  acquire(&shmtable.lock);
80105c39:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
80105c40:	e8 be 03 00 00       	call   80106003 <acquire>
  if(shmtable.shmarray[shmid].size > 0){
80105c45:	8b 45 08             	mov    0x8(%ebp),%eax
80105c48:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105c4e:	05 e0 1f 11 80       	add    $0x80111fe0,%eax
80105c53:	8b 40 0c             	mov    0xc(%eax),%eax
80105c56:	85 c0                	test   %eax,%eax
80105c58:	0f 84 81 01 00 00    	je     80105ddf <shmat+0x1ba>
    size = PGROUNDUP(proc->sz);
80105c5e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c64:	8b 00                	mov    (%eax),%eax
80105c66:	05 ff 0f 00 00       	add    $0xfff,%eax
80105c6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80105c70:	89 45 f4             	mov    %eax,-0xc(%ebp)
    ret =(void*)size;
80105c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(size + PGSIZE >= KERNBASE){
80105c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7c:	05 00 10 00 00       	add    $0x1000,%eax
80105c81:	85 c0                	test   %eax,%eax
80105c83:	79 22                	jns    80105ca7 <shmat+0x82>
      cprintf("shmat:not enogh memory\n");
80105c85:	c7 04 24 a7 9c 10 80 	movl   $0x80109ca7,(%esp)
80105c8c:	e8 10 a7 ff ff       	call   801003a1 <cprintf>
      release(&shmtable.lock);
80105c91:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
80105c98:	e8 de 03 00 00       	call   8010607b <release>
      return (void*)-1;
80105c9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca2:	e9 8e 01 00 00       	jmp    80105e35 <shmat+0x210>
    }
    //all is fine
    for(i = 0;shmtable.shmarray[shmid].addr[i] && size < KERNBASE;i++){
80105ca7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105cae:	e9 bd 00 00 00       	jmp    80105d70 <shmat+0x14b>
      //find the adress of the memory
      memory = shmtable.shmarray[shmid].addr[i];
80105cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb6:	6b c0 33             	imul   $0x33,%eax,%eax
80105cb9:	03 45 ec             	add    -0x14(%ebp),%eax
80105cbc:	83 c0 18             	add    $0x18,%eax
80105cbf:	8b 04 85 90 1f 11 80 	mov    -0x7feee070(,%eax,4),%eax
80105cc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      flag_for =1; //we did at least one page
80105cc9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
      if(shmflg == SHM_RDONLY){
80105cd0:	83 7d 0c 16          	cmpl   $0x16,0xc(%ebp)
80105cd4:	75 41                	jne    80105d17 <shmat+0xf2>
	mappages(proc->pgdir, (char*)size, PGSIZE, v2p(memory), PTE_U); 
80105cd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cd9:	89 04 24             	mov    %eax,(%esp)
80105cdc:	e8 df e2 ff ff       	call   80103fc0 <v2p>
80105ce1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105ce4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105ceb:	8b 52 04             	mov    0x4(%edx),%edx
80105cee:	c7 44 24 10 04 00 00 	movl   $0x4,0x10(%esp)
80105cf5:	00 
80105cf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
80105cfa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105d01:	00 
80105d02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105d06:	89 14 24             	mov    %edx,(%esp)
80105d09:	e8 d3 31 00 00       	call   80108ee1 <mappages>
	size += PGSIZE;
80105d0e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
	break;
80105d15:	eb 7b                	jmp    80105d92 <shmat+0x16d>
      }
      else if(shmflg == SHM_RDWR){
80105d17:	83 7d 0c 17          	cmpl   $0x17,0xc(%ebp)
80105d1b:	75 41                	jne    80105d5e <shmat+0x139>
	mappages(proc->pgdir, (char*)size, PGSIZE, v2p(memory), PTE_W|PTE_U);
80105d1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d20:	89 04 24             	mov    %eax,(%esp)
80105d23:	e8 98 e2 ff ff       	call   80103fc0 <v2p>
80105d28:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105d2b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105d32:	8b 52 04             	mov    0x4(%edx),%edx
80105d35:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80105d3c:	00 
80105d3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80105d41:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105d48:	00 
80105d49:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105d4d:	89 14 24             	mov    %edx,(%esp)
80105d50:	e8 8c 31 00 00       	call   80108ee1 <mappages>
	size += PGSIZE;
80105d55:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
	break;
80105d5c:	eb 34                	jmp    80105d92 <shmat+0x16d>
      }
      else{//default
	flag_for = 0;
80105d5e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	size += PGSIZE;
80105d65:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
      cprintf("shmat:not enogh memory\n");
      release(&shmtable.lock);
      return (void*)-1;
    }
    //all is fine
    for(i = 0;shmtable.shmarray[shmid].addr[i] && size < KERNBASE;i++){
80105d6c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80105d70:	8b 45 08             	mov    0x8(%ebp),%eax
80105d73:	6b c0 33             	imul   $0x33,%eax,%eax
80105d76:	03 45 ec             	add    -0x14(%ebp),%eax
80105d79:	83 c0 18             	add    $0x18,%eax
80105d7c:	8b 04 85 90 1f 11 80 	mov    -0x7feee070(,%eax,4),%eax
80105d83:	85 c0                	test   %eax,%eax
80105d85:	74 0b                	je     80105d92 <shmat+0x16d>
80105d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8a:	85 c0                	test   %eax,%eax
80105d8c:	0f 89 21 ff ff ff    	jns    80105cb3 <shmat+0x8e>
      else{//default
	flag_for = 0;
	size += PGSIZE;
      }
    }//end of for 
    if(flag_for){
80105d92:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80105d96:	74 32                	je     80105dca <shmat+0x1a5>
      proc->sz =size;
80105d98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105da1:	89 10                	mov    %edx,(%eax)
      shmtable.shmarray[shmid].linkcounter++;
80105da3:	8b 45 08             	mov    0x8(%ebp),%eax
80105da6:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105dac:	05 70 20 11 80       	add    $0x80112070,%eax
80105db1:	8b 40 0c             	mov    0xc(%eax),%eax
80105db4:	8d 50 01             	lea    0x1(%eax),%edx
80105db7:	8b 45 08             	mov    0x8(%ebp),%eax
80105dba:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105dc0:	05 70 20 11 80       	add    $0x80112070,%eax
80105dc5:	89 50 0c             	mov    %edx,0xc(%eax)
80105dc8:	eb 34                	jmp    80105dfe <shmat+0x1d9>
    }
    else{
      ret =(void*) -1;
80105dca:	c7 45 f0 ff ff ff ff 	movl   $0xffffffff,-0x10(%ebp)
      cprintf("shmat: no shmflg (flag_for = 0\n");
80105dd1:	c7 04 24 c0 9c 10 80 	movl   $0x80109cc0,(%esp)
80105dd8:	e8 c4 a5 ff ff       	call   801003a1 <cprintf>
80105ddd:	eb 1f                	jmp    80105dfe <shmat+0x1d9>
    }
  }
  else{ 
    cprintf("shmat: the memory isn't there\n");
80105ddf:	c7 04 24 e0 9c 10 80 	movl   $0x80109ce0,(%esp)
80105de6:	e8 b6 a5 ff ff       	call   801003a1 <cprintf>
    release(&shmtable.lock);
80105deb:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
80105df2:	e8 84 02 00 00       	call   8010607b <release>
    return (void*)-1;
80105df7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfc:	eb 37                	jmp    80105e35 <shmat+0x210>
  }
  shmtable.shmarray[shmid].virtual_addr =ret;
80105dfe:	8b 45 08             	mov    0x8(%ebp),%eax
80105e01:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105e07:	8d 90 60 20 11 80    	lea    -0x7feedfa0(%eax),%edx
80105e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e10:	89 42 10             	mov    %eax,0x10(%edx)
  proc->va[shmid]=ret;
80105e13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e19:	8b 55 08             	mov    0x8(%ebp),%edx
80105e1c:	8d 4a 20             	lea    0x20(%edx),%ecx
80105e1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e22:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
  release(&shmtable.lock);
80105e26:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
80105e2d:	e8 49 02 00 00       	call   8010607b <release>
  return ret; 
80105e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105e35:	c9                   	leave  
80105e36:	c3                   	ret    

80105e37 <shmdt>:

int shmdt(const void *shmaddr){
80105e37:	55                   	push   %ebp
80105e38:	89 e5                	mov    %esp,%ebp
80105e3a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint numOfPages;
  pte = walkpgdir(proc->pgdir, (char*)shmaddr, 0);
80105e3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e43:	8b 40 04             	mov    0x4(%eax),%eax
80105e46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e4d:	00 
80105e4e:	8b 55 08             	mov    0x8(%ebp),%edx
80105e51:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e55:	89 04 24             	mov    %eax,(%esp)
80105e58:	e8 ee 2f 00 00       	call   80108e4b <walkpgdir>
80105e5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  acquire(&shmtable.lock);
80105e60:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
80105e67:	e8 97 01 00 00       	call   80106003 <acquire>
  int shmid = find_key(shmaddr);
80105e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80105e6f:	89 04 24             	mov    %eax,(%esp)
80105e72:	e8 69 fd ff ff       	call   80105be0 <find_key>
80105e77:	89 45 ec             	mov    %eax,-0x14(%ebp)
  shmtable.shmarray[shmid].linkcounter--;
80105e7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e7d:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105e83:	05 70 20 11 80       	add    $0x80112070,%eax
80105e88:	8b 40 0c             	mov    0xc(%eax),%eax
80105e8b:	8d 50 ff             	lea    -0x1(%eax),%edx
80105e8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105e91:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105e97:	05 70 20 11 80       	add    $0x80112070,%eax
80105e9c:	89 50 0c             	mov    %edx,0xc(%eax)
  numOfPages = shmtable.shmarray[shmid].pages_amount;
80105e9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105ea2:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105ea8:	05 70 20 11 80       	add    $0x80112070,%eax
80105ead:	8b 40 08             	mov    0x8(%eax),%eax
80105eb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  void *shmaddr2 = (void*)shmaddr;
80105eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80105eb6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  for(; shmaddr2  < shmaddr + numOfPages*PGSIZE; shmaddr2 += PGSIZE)
80105eb9:	eb 40                	jmp    80105efb <shmdt+0xc4>
  {
    pte = walkpgdir(proc->pgdir, (char*)shmaddr2, 0);
80105ebb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ec1:	8b 40 04             	mov    0x4(%eax),%eax
80105ec4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105ecb:	00 
80105ecc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ecf:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ed3:	89 04 24             	mov    %eax,(%esp)
80105ed6:	e8 70 2f 00 00       	call   80108e4b <walkpgdir>
80105edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80105ede:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ee2:	75 07                	jne    80105eeb <shmdt+0xb4>
      shmaddr2 += (NPTENTRIES - 1) * PGSIZE;
80105ee4:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
    *pte = 0;
80105eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  int shmid = find_key(shmaddr);
  shmtable.shmarray[shmid].linkcounter--;
  numOfPages = shmtable.shmarray[shmid].pages_amount;
  void *shmaddr2 = (void*)shmaddr;
  
  for(; shmaddr2  < shmaddr + numOfPages*PGSIZE; shmaddr2 += PGSIZE)
80105ef4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80105efb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105efe:	c1 e0 0c             	shl    $0xc,%eax
80105f01:	03 45 08             	add    0x8(%ebp),%eax
80105f04:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105f07:	77 b2                	ja     80105ebb <shmdt+0x84>
    pte = walkpgdir(proc->pgdir, (char*)shmaddr2, 0);
    if(!pte)
      shmaddr2 += (NPTENTRIES - 1) * PGSIZE;
    *pte = 0;
  }
  if(!shmtable.shmarray[shmid].linkcounter){
80105f09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f0c:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105f12:	05 70 20 11 80       	add    $0x80112070,%eax
80105f17:	8b 40 0c             	mov    0xc(%eax),%eax
80105f1a:	85 c0                	test   %eax,%eax
80105f1c:	75 2c                	jne    80105f4a <shmdt+0x113>
    shmtable.shmarray[shmid].shmstate = UNLINKED;
80105f1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f21:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105f27:	05 70 20 11 80       	add    $0x80112070,%eax
80105f2c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
    cprintf("freeing all the memory\n");
80105f33:	c7 04 24 ff 9c 10 80 	movl   $0x80109cff,(%esp)
80105f3a:	e8 62 a4 ff ff       	call   801003a1 <cprintf>
    shmdel(shmid);
80105f3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f42:	89 04 24             	mov    %eax,(%esp)
80105f45:	e8 d1 fb ff ff       	call   80105b1b <shmdel>
  }
 release(&shmtable.lock);
80105f4a:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
80105f51:	e8 25 01 00 00       	call   8010607b <release>
 return 0; 
80105f56:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f5b:	c9                   	leave  
80105f5c:	c3                   	ret    

80105f5d <get_share_memory_address>:
void* get_share_memory_address(int key){
80105f5d:	55                   	push   %ebp
80105f5e:	89 e5                	mov    %esp,%ebp
80105f60:	83 ec 28             	sub    $0x28,%esp
  void * ret =0;
80105f63:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  acquire(&shmtable.lock);
80105f6a:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
80105f71:	e8 8d 00 00 00       	call   80106003 <acquire>
  ret = shmtable.shmarray[key].addr[0];
80105f76:	8b 45 08             	mov    0x8(%ebp),%eax
80105f79:	69 c0 cc 00 00 00    	imul   $0xcc,%eax,%eax
80105f7f:	05 e0 1f 11 80       	add    $0x80111fe0,%eax
80105f84:	8b 40 10             	mov    0x10(%eax),%eax
80105f87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&shmtable.lock);
80105f8a:	c7 04 24 80 1f 11 80 	movl   $0x80111f80,(%esp)
80105f91:	e8 e5 00 00 00       	call   8010607b <release>
 return ret;
80105f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f99:	c9                   	leave  
80105f9a:	c3                   	ret    
	...

80105f9c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105f9c:	55                   	push   %ebp
80105f9d:	89 e5                	mov    %esp,%ebp
80105f9f:	53                   	push   %ebx
80105fa0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105fa3:	9c                   	pushf  
80105fa4:	5b                   	pop    %ebx
80105fa5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80105fa8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105fab:	83 c4 10             	add    $0x10,%esp
80105fae:	5b                   	pop    %ebx
80105faf:	5d                   	pop    %ebp
80105fb0:	c3                   	ret    

80105fb1 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105fb1:	55                   	push   %ebp
80105fb2:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105fb4:	fa                   	cli    
}
80105fb5:	5d                   	pop    %ebp
80105fb6:	c3                   	ret    

80105fb7 <sti>:

static inline void
sti(void)
{
80105fb7:	55                   	push   %ebp
80105fb8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105fba:	fb                   	sti    
}
80105fbb:	5d                   	pop    %ebp
80105fbc:	c3                   	ret    

80105fbd <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105fbd:	55                   	push   %ebp
80105fbe:	89 e5                	mov    %esp,%ebp
80105fc0:	53                   	push   %ebx
80105fc1:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105fc4:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80105fca:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105fcd:	89 c3                	mov    %eax,%ebx
80105fcf:	89 d8                	mov    %ebx,%eax
80105fd1:	f0 87 02             	lock xchg %eax,(%edx)
80105fd4:	89 c3                	mov    %eax,%ebx
80105fd6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105fd9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105fdc:	83 c4 10             	add    $0x10,%esp
80105fdf:	5b                   	pop    %ebx
80105fe0:	5d                   	pop    %ebp
80105fe1:	c3                   	ret    

80105fe2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105fe2:	55                   	push   %ebp
80105fe3:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe8:	8b 55 0c             	mov    0xc(%ebp),%edx
80105feb:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105fee:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80105ffa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80106001:	5d                   	pop    %ebp
80106002:	c3                   	ret    

80106003 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80106003:	55                   	push   %ebp
80106004:	89 e5                	mov    %esp,%ebp
80106006:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80106009:	e8 53 01 00 00       	call   80106161 <pushcli>
  if(holding(lk)){
8010600e:	8b 45 08             	mov    0x8(%ebp),%eax
80106011:	89 04 24             	mov    %eax,(%esp)
80106014:	e8 1e 01 00 00       	call   80106137 <holding>
80106019:	85 c0                	test   %eax,%eax
8010601b:	74 22                	je     8010603f <acquire+0x3c>
    cprintf("acquire spinlock.c->lk: %s\n",lk->name);
8010601d:	8b 45 08             	mov    0x8(%ebp),%eax
80106020:	8b 40 04             	mov    0x4(%eax),%eax
80106023:	89 44 24 04          	mov    %eax,0x4(%esp)
80106027:	c7 04 24 67 9d 10 80 	movl   $0x80109d67,(%esp)
8010602e:	e8 6e a3 ff ff       	call   801003a1 <cprintf>
    panic("acquire");
80106033:	c7 04 24 83 9d 10 80 	movl   $0x80109d83,(%esp)
8010603a:	e8 fe a4 ff ff       	call   8010053d <panic>
  }

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
8010603f:	90                   	nop
80106040:	8b 45 08             	mov    0x8(%ebp),%eax
80106043:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010604a:	00 
8010604b:	89 04 24             	mov    %eax,(%esp)
8010604e:	e8 6a ff ff ff       	call   80105fbd <xchg>
80106053:	85 c0                	test   %eax,%eax
80106055:	75 e9                	jne    80106040 <acquire+0x3d>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80106057:	8b 45 08             	mov    0x8(%ebp),%eax
8010605a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106061:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80106064:	8b 45 08             	mov    0x8(%ebp),%eax
80106067:	83 c0 0c             	add    $0xc,%eax
8010606a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010606e:	8d 45 08             	lea    0x8(%ebp),%eax
80106071:	89 04 24             	mov    %eax,(%esp)
80106074:	e8 51 00 00 00       	call   801060ca <getcallerpcs>
}
80106079:	c9                   	leave  
8010607a:	c3                   	ret    

8010607b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010607b:	55                   	push   %ebp
8010607c:	89 e5                	mov    %esp,%ebp
8010607e:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80106081:	8b 45 08             	mov    0x8(%ebp),%eax
80106084:	89 04 24             	mov    %eax,(%esp)
80106087:	e8 ab 00 00 00       	call   80106137 <holding>
8010608c:	85 c0                	test   %eax,%eax
8010608e:	75 0c                	jne    8010609c <release+0x21>
    panic("release");
80106090:	c7 04 24 8b 9d 10 80 	movl   $0x80109d8b,(%esp)
80106097:	e8 a1 a4 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
8010609c:	8b 45 08             	mov    0x8(%ebp),%eax
8010609f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801060a6:	8b 45 08             	mov    0x8(%ebp),%eax
801060a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801060b0:	8b 45 08             	mov    0x8(%ebp),%eax
801060b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801060ba:	00 
801060bb:	89 04 24             	mov    %eax,(%esp)
801060be:	e8 fa fe ff ff       	call   80105fbd <xchg>

  popcli();
801060c3:	e8 e1 00 00 00       	call   801061a9 <popcli>
}
801060c8:	c9                   	leave  
801060c9:	c3                   	ret    

801060ca <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801060ca:	55                   	push   %ebp
801060cb:	89 e5                	mov    %esp,%ebp
801060cd:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801060d0:	8b 45 08             	mov    0x8(%ebp),%eax
801060d3:	83 e8 08             	sub    $0x8,%eax
801060d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801060d9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801060e0:	eb 32                	jmp    80106114 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801060e2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801060e6:	74 47                	je     8010612f <getcallerpcs+0x65>
801060e8:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801060ef:	76 3e                	jbe    8010612f <getcallerpcs+0x65>
801060f1:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801060f5:	74 38                	je     8010612f <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
801060f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801060fa:	c1 e0 02             	shl    $0x2,%eax
801060fd:	03 45 0c             	add    0xc(%ebp),%eax
80106100:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106103:	8b 52 04             	mov    0x4(%edx),%edx
80106106:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80106108:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010610b:	8b 00                	mov    (%eax),%eax
8010610d:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80106110:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80106114:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106118:	7e c8                	jle    801060e2 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010611a:	eb 13                	jmp    8010612f <getcallerpcs+0x65>
    pcs[i] = 0;
8010611c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010611f:	c1 e0 02             	shl    $0x2,%eax
80106122:	03 45 0c             	add    0xc(%ebp),%eax
80106125:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010612b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010612f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80106133:	7e e7                	jle    8010611c <getcallerpcs+0x52>
    pcs[i] = 0;
}
80106135:	c9                   	leave  
80106136:	c3                   	ret    

80106137 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80106137:	55                   	push   %ebp
80106138:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010613a:	8b 45 08             	mov    0x8(%ebp),%eax
8010613d:	8b 00                	mov    (%eax),%eax
8010613f:	85 c0                	test   %eax,%eax
80106141:	74 17                	je     8010615a <holding+0x23>
80106143:	8b 45 08             	mov    0x8(%ebp),%eax
80106146:	8b 50 08             	mov    0x8(%eax),%edx
80106149:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010614f:	39 c2                	cmp    %eax,%edx
80106151:	75 07                	jne    8010615a <holding+0x23>
80106153:	b8 01 00 00 00       	mov    $0x1,%eax
80106158:	eb 05                	jmp    8010615f <holding+0x28>
8010615a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010615f:	5d                   	pop    %ebp
80106160:	c3                   	ret    

80106161 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80106161:	55                   	push   %ebp
80106162:	89 e5                	mov    %esp,%ebp
80106164:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80106167:	e8 30 fe ff ff       	call   80105f9c <readeflags>
8010616c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010616f:	e8 3d fe ff ff       	call   80105fb1 <cli>
  if(cpu->ncli++ == 0)
80106174:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010617a:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80106180:	85 d2                	test   %edx,%edx
80106182:	0f 94 c1             	sete   %cl
80106185:	83 c2 01             	add    $0x1,%edx
80106188:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010618e:	84 c9                	test   %cl,%cl
80106190:	74 15                	je     801061a7 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80106192:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106198:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010619b:	81 e2 00 02 00 00    	and    $0x200,%edx
801061a1:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801061a7:	c9                   	leave  
801061a8:	c3                   	ret    

801061a9 <popcli>:

void
popcli(void)
{
801061a9:	55                   	push   %ebp
801061aa:	89 e5                	mov    %esp,%ebp
801061ac:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801061af:	e8 e8 fd ff ff       	call   80105f9c <readeflags>
801061b4:	25 00 02 00 00       	and    $0x200,%eax
801061b9:	85 c0                	test   %eax,%eax
801061bb:	74 0c                	je     801061c9 <popcli+0x20>
    panic("popcli - interruptible");
801061bd:	c7 04 24 93 9d 10 80 	movl   $0x80109d93,(%esp)
801061c4:	e8 74 a3 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
801061c9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801061cf:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801061d5:	83 ea 01             	sub    $0x1,%edx
801061d8:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801061de:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801061e4:	85 c0                	test   %eax,%eax
801061e6:	79 0c                	jns    801061f4 <popcli+0x4b>
    panic("popcli");
801061e8:	c7 04 24 aa 9d 10 80 	movl   $0x80109daa,(%esp)
801061ef:	e8 49 a3 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
801061f4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801061fa:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106200:	85 c0                	test   %eax,%eax
80106202:	75 15                	jne    80106219 <popcli+0x70>
80106204:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010620a:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106210:	85 c0                	test   %eax,%eax
80106212:	74 05                	je     80106219 <popcli+0x70>
    sti();
80106214:	e8 9e fd ff ff       	call   80105fb7 <sti>
}
80106219:	c9                   	leave  
8010621a:	c3                   	ret    
	...

8010621c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010621c:	55                   	push   %ebp
8010621d:	89 e5                	mov    %esp,%ebp
8010621f:	57                   	push   %edi
80106220:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106221:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106224:	8b 55 10             	mov    0x10(%ebp),%edx
80106227:	8b 45 0c             	mov    0xc(%ebp),%eax
8010622a:	89 cb                	mov    %ecx,%ebx
8010622c:	89 df                	mov    %ebx,%edi
8010622e:	89 d1                	mov    %edx,%ecx
80106230:	fc                   	cld    
80106231:	f3 aa                	rep stos %al,%es:(%edi)
80106233:	89 ca                	mov    %ecx,%edx
80106235:	89 fb                	mov    %edi,%ebx
80106237:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010623a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010623d:	5b                   	pop    %ebx
8010623e:	5f                   	pop    %edi
8010623f:	5d                   	pop    %ebp
80106240:	c3                   	ret    

80106241 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80106241:	55                   	push   %ebp
80106242:	89 e5                	mov    %esp,%ebp
80106244:	57                   	push   %edi
80106245:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80106246:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106249:	8b 55 10             	mov    0x10(%ebp),%edx
8010624c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010624f:	89 cb                	mov    %ecx,%ebx
80106251:	89 df                	mov    %ebx,%edi
80106253:	89 d1                	mov    %edx,%ecx
80106255:	fc                   	cld    
80106256:	f3 ab                	rep stos %eax,%es:(%edi)
80106258:	89 ca                	mov    %ecx,%edx
8010625a:	89 fb                	mov    %edi,%ebx
8010625c:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010625f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80106262:	5b                   	pop    %ebx
80106263:	5f                   	pop    %edi
80106264:	5d                   	pop    %ebp
80106265:	c3                   	ret    

80106266 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80106266:	55                   	push   %ebp
80106267:	89 e5                	mov    %esp,%ebp
80106269:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
8010626c:	8b 45 08             	mov    0x8(%ebp),%eax
8010626f:	83 e0 03             	and    $0x3,%eax
80106272:	85 c0                	test   %eax,%eax
80106274:	75 49                	jne    801062bf <memset+0x59>
80106276:	8b 45 10             	mov    0x10(%ebp),%eax
80106279:	83 e0 03             	and    $0x3,%eax
8010627c:	85 c0                	test   %eax,%eax
8010627e:	75 3f                	jne    801062bf <memset+0x59>
    c &= 0xFF;
80106280:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80106287:	8b 45 10             	mov    0x10(%ebp),%eax
8010628a:	c1 e8 02             	shr    $0x2,%eax
8010628d:	89 c2                	mov    %eax,%edx
8010628f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106292:	89 c1                	mov    %eax,%ecx
80106294:	c1 e1 18             	shl    $0x18,%ecx
80106297:	8b 45 0c             	mov    0xc(%ebp),%eax
8010629a:	c1 e0 10             	shl    $0x10,%eax
8010629d:	09 c1                	or     %eax,%ecx
8010629f:	8b 45 0c             	mov    0xc(%ebp),%eax
801062a2:	c1 e0 08             	shl    $0x8,%eax
801062a5:	09 c8                	or     %ecx,%eax
801062a7:	0b 45 0c             	or     0xc(%ebp),%eax
801062aa:	89 54 24 08          	mov    %edx,0x8(%esp)
801062ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801062b2:	8b 45 08             	mov    0x8(%ebp),%eax
801062b5:	89 04 24             	mov    %eax,(%esp)
801062b8:	e8 84 ff ff ff       	call   80106241 <stosl>
801062bd:	eb 19                	jmp    801062d8 <memset+0x72>
  } else
    stosb(dst, c, n);
801062bf:	8b 45 10             	mov    0x10(%ebp),%eax
801062c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801062c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801062c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801062cd:	8b 45 08             	mov    0x8(%ebp),%eax
801062d0:	89 04 24             	mov    %eax,(%esp)
801062d3:	e8 44 ff ff ff       	call   8010621c <stosb>
  return dst;
801062d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801062db:	c9                   	leave  
801062dc:	c3                   	ret    

801062dd <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801062dd:	55                   	push   %ebp
801062de:	89 e5                	mov    %esp,%ebp
801062e0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801062e3:	8b 45 08             	mov    0x8(%ebp),%eax
801062e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801062e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801062ec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801062ef:	eb 32                	jmp    80106323 <memcmp+0x46>
    if(*s1 != *s2)
801062f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062f4:	0f b6 10             	movzbl (%eax),%edx
801062f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801062fa:	0f b6 00             	movzbl (%eax),%eax
801062fd:	38 c2                	cmp    %al,%dl
801062ff:	74 1a                	je     8010631b <memcmp+0x3e>
      return *s1 - *s2;
80106301:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106304:	0f b6 00             	movzbl (%eax),%eax
80106307:	0f b6 d0             	movzbl %al,%edx
8010630a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010630d:	0f b6 00             	movzbl (%eax),%eax
80106310:	0f b6 c0             	movzbl %al,%eax
80106313:	89 d1                	mov    %edx,%ecx
80106315:	29 c1                	sub    %eax,%ecx
80106317:	89 c8                	mov    %ecx,%eax
80106319:	eb 1c                	jmp    80106337 <memcmp+0x5a>
    s1++, s2++;
8010631b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010631f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80106323:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106327:	0f 95 c0             	setne  %al
8010632a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010632e:	84 c0                	test   %al,%al
80106330:	75 bf                	jne    801062f1 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80106332:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106337:	c9                   	leave  
80106338:	c3                   	ret    

80106339 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106339:	55                   	push   %ebp
8010633a:	89 e5                	mov    %esp,%ebp
8010633c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010633f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106342:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106345:	8b 45 08             	mov    0x8(%ebp),%eax
80106348:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010634b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010634e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106351:	73 54                	jae    801063a7 <memmove+0x6e>
80106353:	8b 45 10             	mov    0x10(%ebp),%eax
80106356:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106359:	01 d0                	add    %edx,%eax
8010635b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010635e:	76 47                	jbe    801063a7 <memmove+0x6e>
    s += n;
80106360:	8b 45 10             	mov    0x10(%ebp),%eax
80106363:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106366:	8b 45 10             	mov    0x10(%ebp),%eax
80106369:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010636c:	eb 13                	jmp    80106381 <memmove+0x48>
      *--d = *--s;
8010636e:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80106372:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106376:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106379:	0f b6 10             	movzbl (%eax),%edx
8010637c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010637f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80106381:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106385:	0f 95 c0             	setne  %al
80106388:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010638c:	84 c0                	test   %al,%al
8010638e:	75 de                	jne    8010636e <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80106390:	eb 25                	jmp    801063b7 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80106392:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106395:	0f b6 10             	movzbl (%eax),%edx
80106398:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010639b:	88 10                	mov    %dl,(%eax)
8010639d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801063a1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801063a5:	eb 01                	jmp    801063a8 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801063a7:	90                   	nop
801063a8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801063ac:	0f 95 c0             	setne  %al
801063af:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801063b3:	84 c0                	test   %al,%al
801063b5:	75 db                	jne    80106392 <memmove+0x59>
      *d++ = *s++;

  return dst;
801063b7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801063ba:	c9                   	leave  
801063bb:	c3                   	ret    

801063bc <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801063bc:	55                   	push   %ebp
801063bd:	89 e5                	mov    %esp,%ebp
801063bf:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801063c2:	8b 45 10             	mov    0x10(%ebp),%eax
801063c5:	89 44 24 08          	mov    %eax,0x8(%esp)
801063c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801063cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801063d0:	8b 45 08             	mov    0x8(%ebp),%eax
801063d3:	89 04 24             	mov    %eax,(%esp)
801063d6:	e8 5e ff ff ff       	call   80106339 <memmove>
}
801063db:	c9                   	leave  
801063dc:	c3                   	ret    

801063dd <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801063dd:	55                   	push   %ebp
801063de:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801063e0:	eb 0c                	jmp    801063ee <strncmp+0x11>
    n--, p++, q++;
801063e2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801063e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801063ea:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801063ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801063f2:	74 1a                	je     8010640e <strncmp+0x31>
801063f4:	8b 45 08             	mov    0x8(%ebp),%eax
801063f7:	0f b6 00             	movzbl (%eax),%eax
801063fa:	84 c0                	test   %al,%al
801063fc:	74 10                	je     8010640e <strncmp+0x31>
801063fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106401:	0f b6 10             	movzbl (%eax),%edx
80106404:	8b 45 0c             	mov    0xc(%ebp),%eax
80106407:	0f b6 00             	movzbl (%eax),%eax
8010640a:	38 c2                	cmp    %al,%dl
8010640c:	74 d4                	je     801063e2 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010640e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106412:	75 07                	jne    8010641b <strncmp+0x3e>
    return 0;
80106414:	b8 00 00 00 00       	mov    $0x0,%eax
80106419:	eb 18                	jmp    80106433 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
8010641b:	8b 45 08             	mov    0x8(%ebp),%eax
8010641e:	0f b6 00             	movzbl (%eax),%eax
80106421:	0f b6 d0             	movzbl %al,%edx
80106424:	8b 45 0c             	mov    0xc(%ebp),%eax
80106427:	0f b6 00             	movzbl (%eax),%eax
8010642a:	0f b6 c0             	movzbl %al,%eax
8010642d:	89 d1                	mov    %edx,%ecx
8010642f:	29 c1                	sub    %eax,%ecx
80106431:	89 c8                	mov    %ecx,%eax
}
80106433:	5d                   	pop    %ebp
80106434:	c3                   	ret    

80106435 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80106435:	55                   	push   %ebp
80106436:	89 e5                	mov    %esp,%ebp
80106438:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010643b:	8b 45 08             	mov    0x8(%ebp),%eax
8010643e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80106441:	90                   	nop
80106442:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106446:	0f 9f c0             	setg   %al
80106449:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010644d:	84 c0                	test   %al,%al
8010644f:	74 30                	je     80106481 <strncpy+0x4c>
80106451:	8b 45 0c             	mov    0xc(%ebp),%eax
80106454:	0f b6 10             	movzbl (%eax),%edx
80106457:	8b 45 08             	mov    0x8(%ebp),%eax
8010645a:	88 10                	mov    %dl,(%eax)
8010645c:	8b 45 08             	mov    0x8(%ebp),%eax
8010645f:	0f b6 00             	movzbl (%eax),%eax
80106462:	84 c0                	test   %al,%al
80106464:	0f 95 c0             	setne  %al
80106467:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010646b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010646f:	84 c0                	test   %al,%al
80106471:	75 cf                	jne    80106442 <strncpy+0xd>
    ;
  while(n-- > 0)
80106473:	eb 0c                	jmp    80106481 <strncpy+0x4c>
    *s++ = 0;
80106475:	8b 45 08             	mov    0x8(%ebp),%eax
80106478:	c6 00 00             	movb   $0x0,(%eax)
8010647b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010647f:	eb 01                	jmp    80106482 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106481:	90                   	nop
80106482:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106486:	0f 9f c0             	setg   %al
80106489:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010648d:	84 c0                	test   %al,%al
8010648f:	75 e4                	jne    80106475 <strncpy+0x40>
    *s++ = 0;
  return os;
80106491:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106494:	c9                   	leave  
80106495:	c3                   	ret    

80106496 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80106496:	55                   	push   %ebp
80106497:	89 e5                	mov    %esp,%ebp
80106499:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010649c:	8b 45 08             	mov    0x8(%ebp),%eax
8010649f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801064a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801064a6:	7f 05                	jg     801064ad <safestrcpy+0x17>
    return os;
801064a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801064ab:	eb 35                	jmp    801064e2 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801064ad:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801064b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801064b5:	7e 22                	jle    801064d9 <safestrcpy+0x43>
801064b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801064ba:	0f b6 10             	movzbl (%eax),%edx
801064bd:	8b 45 08             	mov    0x8(%ebp),%eax
801064c0:	88 10                	mov    %dl,(%eax)
801064c2:	8b 45 08             	mov    0x8(%ebp),%eax
801064c5:	0f b6 00             	movzbl (%eax),%eax
801064c8:	84 c0                	test   %al,%al
801064ca:	0f 95 c0             	setne  %al
801064cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801064d1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801064d5:	84 c0                	test   %al,%al
801064d7:	75 d4                	jne    801064ad <safestrcpy+0x17>
    ;
  *s = 0;
801064d9:	8b 45 08             	mov    0x8(%ebp),%eax
801064dc:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801064df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801064e2:	c9                   	leave  
801064e3:	c3                   	ret    

801064e4 <strlen>:

int
strlen(const char *s)
{
801064e4:	55                   	push   %ebp
801064e5:	89 e5                	mov    %esp,%ebp
801064e7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801064ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801064f1:	eb 04                	jmp    801064f7 <strlen+0x13>
801064f3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801064f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801064fa:	03 45 08             	add    0x8(%ebp),%eax
801064fd:	0f b6 00             	movzbl (%eax),%eax
80106500:	84 c0                	test   %al,%al
80106502:	75 ef                	jne    801064f3 <strlen+0xf>
    ;
  return n;
80106504:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106507:	c9                   	leave  
80106508:	c3                   	ret    
80106509:	00 00                	add    %al,(%eax)
	...

8010650c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010650c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106510:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106514:	55                   	push   %ebp
  pushl %ebx
80106515:	53                   	push   %ebx
  pushl %esi
80106516:	56                   	push   %esi
  pushl %edi
80106517:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106518:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010651a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010651c:	5f                   	pop    %edi
  popl %esi
8010651d:	5e                   	pop    %esi
  popl %ebx
8010651e:	5b                   	pop    %ebx
  popl %ebp
8010651f:	5d                   	pop    %ebp
  ret
80106520:	c3                   	ret    
80106521:	00 00                	add    %al,(%eax)
	...

80106524 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from process p.
int
fetchint(struct proc *p, uint addr, int *ip)
{
80106524:	55                   	push   %ebp
80106525:	89 e5                	mov    %esp,%ebp
  if(addr >= p->sz || addr+4 > p->sz){
80106527:	8b 45 08             	mov    0x8(%ebp),%eax
8010652a:	8b 00                	mov    (%eax),%eax
8010652c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010652f:	76 0f                	jbe    80106540 <fetchint+0x1c>
80106531:	8b 45 0c             	mov    0xc(%ebp),%eax
80106534:	8d 50 04             	lea    0x4(%eax),%edx
80106537:	8b 45 08             	mov    0x8(%ebp),%eax
8010653a:	8b 00                	mov    (%eax),%eax
8010653c:	39 c2                	cmp    %eax,%edx
8010653e:	76 07                	jbe    80106547 <fetchint+0x23>
    return -1;
80106540:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106545:	eb 0f                	jmp    80106556 <fetchint+0x32>
  }
  *ip = *(int*)(addr);
80106547:	8b 45 0c             	mov    0xc(%ebp),%eax
8010654a:	8b 10                	mov    (%eax),%edx
8010654c:	8b 45 10             	mov    0x10(%ebp),%eax
8010654f:	89 10                	mov    %edx,(%eax)
  return 0;
80106551:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106556:	5d                   	pop    %ebp
80106557:	c3                   	ret    

80106558 <fetchstr>:
// Fetch the nul-terminated string at addr from process p.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(struct proc *p, uint addr, char **pp)
{
80106558:	55                   	push   %ebp
80106559:	89 e5                	mov    %esp,%ebp
8010655b:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= p->sz)
8010655e:	8b 45 08             	mov    0x8(%ebp),%eax
80106561:	8b 00                	mov    (%eax),%eax
80106563:	3b 45 0c             	cmp    0xc(%ebp),%eax
80106566:	77 07                	ja     8010656f <fetchstr+0x17>
    return -1;
80106568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656d:	eb 45                	jmp    801065b4 <fetchstr+0x5c>
  *pp = (char*)addr;
8010656f:	8b 55 0c             	mov    0xc(%ebp),%edx
80106572:	8b 45 10             	mov    0x10(%ebp),%eax
80106575:	89 10                	mov    %edx,(%eax)
  ep = (char*)p->sz;
80106577:	8b 45 08             	mov    0x8(%ebp),%eax
8010657a:	8b 00                	mov    (%eax),%eax
8010657c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010657f:	8b 45 10             	mov    0x10(%ebp),%eax
80106582:	8b 00                	mov    (%eax),%eax
80106584:	89 45 fc             	mov    %eax,-0x4(%ebp)
80106587:	eb 1e                	jmp    801065a7 <fetchstr+0x4f>
    if(*s == 0)
80106589:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010658c:	0f b6 00             	movzbl (%eax),%eax
8010658f:	84 c0                	test   %al,%al
80106591:	75 10                	jne    801065a3 <fetchstr+0x4b>
      return s - *pp;
80106593:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106596:	8b 45 10             	mov    0x10(%ebp),%eax
80106599:	8b 00                	mov    (%eax),%eax
8010659b:	89 d1                	mov    %edx,%ecx
8010659d:	29 c1                	sub    %eax,%ecx
8010659f:	89 c8                	mov    %ecx,%eax
801065a1:	eb 11                	jmp    801065b4 <fetchstr+0x5c>

  if(addr >= p->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)p->sz;
  for(s = *pp; s < ep; s++)
801065a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801065a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801065aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801065ad:	72 da                	jb     80106589 <fetchstr+0x31>
    if(*s == 0)
      return s - *pp;
  return -1;
801065af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801065b4:	c9                   	leave  
801065b5:	c3                   	ret    

801065b6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801065b6:	55                   	push   %ebp
801065b7:	89 e5                	mov    %esp,%ebp
801065b9:	83 ec 0c             	sub    $0xc,%esp
  return fetchint(proc, proc->tf->esp + 4 + 4*n, ip);
801065bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065c2:	8b 40 18             	mov    0x18(%eax),%eax
801065c5:	8b 50 44             	mov    0x44(%eax),%edx
801065c8:	8b 45 08             	mov    0x8(%ebp),%eax
801065cb:	c1 e0 02             	shl    $0x2,%eax
801065ce:	01 d0                	add    %edx,%eax
801065d0:	8d 48 04             	lea    0x4(%eax),%ecx
801065d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065d9:	8b 55 0c             	mov    0xc(%ebp),%edx
801065dc:	89 54 24 08          	mov    %edx,0x8(%esp)
801065e0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
801065e4:	89 04 24             	mov    %eax,(%esp)
801065e7:	e8 38 ff ff ff       	call   80106524 <fetchint>
}
801065ec:	c9                   	leave  
801065ed:	c3                   	ret    

801065ee <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801065ee:	55                   	push   %ebp
801065ef:	89 e5                	mov    %esp,%ebp
801065f1:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801065f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
801065f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801065fb:	8b 45 08             	mov    0x8(%ebp),%eax
801065fe:	89 04 24             	mov    %eax,(%esp)
80106601:	e8 b0 ff ff ff       	call   801065b6 <argint>
80106606:	85 c0                	test   %eax,%eax
80106608:	79 07                	jns    80106611 <argptr+0x23>
    return -1;
8010660a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010660f:	eb 3d                	jmp    8010664e <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz){
80106611:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106614:	89 c2                	mov    %eax,%edx
80106616:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010661c:	8b 00                	mov    (%eax),%eax
8010661e:	39 c2                	cmp    %eax,%edx
80106620:	73 16                	jae    80106638 <argptr+0x4a>
80106622:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106625:	89 c2                	mov    %eax,%edx
80106627:	8b 45 10             	mov    0x10(%ebp),%eax
8010662a:	01 c2                	add    %eax,%edx
8010662c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106632:	8b 00                	mov    (%eax),%eax
80106634:	39 c2                	cmp    %eax,%edx
80106636:	76 07                	jbe    8010663f <argptr+0x51>
    return -1;
80106638:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663d:	eb 0f                	jmp    8010664e <argptr+0x60>
  }
  *pp = (char*)i;
8010663f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106642:	89 c2                	mov    %eax,%edx
80106644:	8b 45 0c             	mov    0xc(%ebp),%eax
80106647:	89 10                	mov    %edx,(%eax)
  return 0;
80106649:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010664e:	c9                   	leave  
8010664f:	c3                   	ret    

80106650 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80106650:	55                   	push   %ebp
80106651:	89 e5                	mov    %esp,%ebp
80106653:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106656:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106659:	89 44 24 04          	mov    %eax,0x4(%esp)
8010665d:	8b 45 08             	mov    0x8(%ebp),%eax
80106660:	89 04 24             	mov    %eax,(%esp)
80106663:	e8 4e ff ff ff       	call   801065b6 <argint>
80106668:	85 c0                	test   %eax,%eax
8010666a:	79 07                	jns    80106673 <argstr+0x23>
    return -1;
8010666c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106671:	eb 1e                	jmp    80106691 <argstr+0x41>
  return fetchstr(proc, addr, pp);
80106673:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106676:	89 c2                	mov    %eax,%edx
80106678:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010667e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106681:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106685:	89 54 24 04          	mov    %edx,0x4(%esp)
80106689:	89 04 24             	mov    %eax,(%esp)
8010668c:	e8 c7 fe ff ff       	call   80106558 <fetchstr>
}
80106691:	c9                   	leave  
80106692:	c3                   	ret    

80106693 <syscall>:
[SYS_get_share_memory_address] sys_get_share_memory_address,
};

void
syscall(void)
{
80106693:	55                   	push   %ebp
80106694:	89 e5                	mov    %esp,%ebp
80106696:	53                   	push   %ebx
80106697:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010669a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066a0:	8b 40 18             	mov    0x18(%eax),%eax
801066a3:	8b 40 1c             	mov    0x1c(%eax),%eax
801066a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num >= 0 && num < SYS_open && syscalls[num]) {
801066a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066ad:	78 2e                	js     801066dd <syscall+0x4a>
801066af:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801066b3:	7f 28                	jg     801066dd <syscall+0x4a>
801066b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b8:	8b 04 85 80 d0 10 80 	mov    -0x7fef2f80(,%eax,4),%eax
801066bf:	85 c0                	test   %eax,%eax
801066c1:	74 1a                	je     801066dd <syscall+0x4a>
    proc->tf->eax = syscalls[num]();
801066c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066c9:	8b 58 18             	mov    0x18(%eax),%ebx
801066cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066cf:	8b 04 85 80 d0 10 80 	mov    -0x7fef2f80(,%eax,4),%eax
801066d6:	ff d0                	call   *%eax
801066d8:	89 43 1c             	mov    %eax,0x1c(%ebx)
801066db:	eb 73                	jmp    80106750 <syscall+0xbd>
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
801066dd:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
801066e1:	7e 30                	jle    80106713 <syscall+0x80>
801066e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e6:	83 f8 1d             	cmp    $0x1d,%eax
801066e9:	77 28                	ja     80106713 <syscall+0x80>
801066eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ee:	8b 04 85 80 d0 10 80 	mov    -0x7fef2f80(,%eax,4),%eax
801066f5:	85 c0                	test   %eax,%eax
801066f7:	74 1a                	je     80106713 <syscall+0x80>
    proc->tf->eax = syscalls[num]();
801066f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066ff:	8b 58 18             	mov    0x18(%eax),%ebx
80106702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106705:	8b 04 85 80 d0 10 80 	mov    -0x7fef2f80(,%eax,4),%eax
8010670c:	ff d0                	call   *%eax
8010670e:	89 43 1c             	mov    %eax,0x1c(%ebx)
80106711:	eb 3d                	jmp    80106750 <syscall+0xbd>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106713:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106719:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010671c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
  if(num >= 0 && num < SYS_open && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else if (num >= SYS_open && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80106722:	8b 40 10             	mov    0x10(%eax),%eax
80106725:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106728:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010672c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106730:	89 44 24 04          	mov    %eax,0x4(%esp)
80106734:	c7 04 24 b1 9d 10 80 	movl   $0x80109db1,(%esp)
8010673b:	e8 61 9c ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106740:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106746:	8b 40 18             	mov    0x18(%eax),%eax
80106749:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106750:	83 c4 24             	add    $0x24,%esp
80106753:	5b                   	pop    %ebx
80106754:	5d                   	pop    %ebp
80106755:	c3                   	ret    
	...

80106758 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106758:	55                   	push   %ebp
80106759:	89 e5                	mov    %esp,%ebp
8010675b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010675e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106761:	89 44 24 04          	mov    %eax,0x4(%esp)
80106765:	8b 45 08             	mov    0x8(%ebp),%eax
80106768:	89 04 24             	mov    %eax,(%esp)
8010676b:	e8 46 fe ff ff       	call   801065b6 <argint>
80106770:	85 c0                	test   %eax,%eax
80106772:	79 07                	jns    8010677b <argfd+0x23>
    return -1;
80106774:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106779:	eb 50                	jmp    801067cb <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010677b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010677e:	85 c0                	test   %eax,%eax
80106780:	78 21                	js     801067a3 <argfd+0x4b>
80106782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106785:	83 f8 0f             	cmp    $0xf,%eax
80106788:	7f 19                	jg     801067a3 <argfd+0x4b>
8010678a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106790:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106793:	83 c2 08             	add    $0x8,%edx
80106796:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010679a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010679d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067a1:	75 07                	jne    801067aa <argfd+0x52>
    return -1;
801067a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a8:	eb 21                	jmp    801067cb <argfd+0x73>
  if(pfd)
801067aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801067ae:	74 08                	je     801067b8 <argfd+0x60>
    *pfd = fd;
801067b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801067b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801067b6:	89 10                	mov    %edx,(%eax)
  if(pf)
801067b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801067bc:	74 08                	je     801067c6 <argfd+0x6e>
    *pf = f;
801067be:	8b 45 10             	mov    0x10(%ebp),%eax
801067c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067c4:	89 10                	mov    %edx,(%eax)
  return 0;
801067c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067cb:	c9                   	leave  
801067cc:	c3                   	ret    

801067cd <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801067cd:	55                   	push   %ebp
801067ce:	89 e5                	mov    %esp,%ebp
801067d0:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801067d3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801067da:	eb 30                	jmp    8010680c <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801067dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801067e5:	83 c2 08             	add    $0x8,%edx
801067e8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801067ec:	85 c0                	test   %eax,%eax
801067ee:	75 18                	jne    80106808 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801067f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801067f9:	8d 4a 08             	lea    0x8(%edx),%ecx
801067fc:	8b 55 08             	mov    0x8(%ebp),%edx
801067ff:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106803:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106806:	eb 0f                	jmp    80106817 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106808:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010680c:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106810:	7e ca                	jle    801067dc <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80106812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106817:	c9                   	leave  
80106818:	c3                   	ret    

80106819 <sys_dup>:

int
sys_dup(void)
{
80106819:	55                   	push   %ebp
8010681a:	89 e5                	mov    %esp,%ebp
8010681c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010681f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106822:	89 44 24 08          	mov    %eax,0x8(%esp)
80106826:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010682d:	00 
8010682e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106835:	e8 1e ff ff ff       	call   80106758 <argfd>
8010683a:	85 c0                	test   %eax,%eax
8010683c:	79 07                	jns    80106845 <sys_dup+0x2c>
    return -1;
8010683e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106843:	eb 29                	jmp    8010686e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106845:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106848:	89 04 24             	mov    %eax,(%esp)
8010684b:	e8 7d ff ff ff       	call   801067cd <fdalloc>
80106850:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106853:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106857:	79 07                	jns    80106860 <sys_dup+0x47>
    return -1;
80106859:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685e:	eb 0e                	jmp    8010686e <sys_dup+0x55>
  filedup(f);
80106860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106863:	89 04 24             	mov    %eax,(%esp)
80106866:	e8 11 a7 ff ff       	call   80100f7c <filedup>
  return fd;
8010686b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010686e:	c9                   	leave  
8010686f:	c3                   	ret    

80106870 <sys_read>:

int
sys_read(void)
{
80106870:	55                   	push   %ebp
80106871:	89 e5                	mov    %esp,%ebp
80106873:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106876:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106879:	89 44 24 08          	mov    %eax,0x8(%esp)
8010687d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106884:	00 
80106885:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010688c:	e8 c7 fe ff ff       	call   80106758 <argfd>
80106891:	85 c0                	test   %eax,%eax
80106893:	78 35                	js     801068ca <sys_read+0x5a>
80106895:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106898:	89 44 24 04          	mov    %eax,0x4(%esp)
8010689c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801068a3:	e8 0e fd ff ff       	call   801065b6 <argint>
801068a8:	85 c0                	test   %eax,%eax
801068aa:	78 1e                	js     801068ca <sys_read+0x5a>
801068ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068af:	89 44 24 08          	mov    %eax,0x8(%esp)
801068b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801068ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801068c1:	e8 28 fd ff ff       	call   801065ee <argptr>
801068c6:	85 c0                	test   %eax,%eax
801068c8:	79 07                	jns    801068d1 <sys_read+0x61>
    return -1;
801068ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cf:	eb 19                	jmp    801068ea <sys_read+0x7a>
  return fileread(f, p, n);
801068d1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801068d4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801068d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801068de:	89 54 24 04          	mov    %edx,0x4(%esp)
801068e2:	89 04 24             	mov    %eax,(%esp)
801068e5:	e8 ff a7 ff ff       	call   801010e9 <fileread>
}
801068ea:	c9                   	leave  
801068eb:	c3                   	ret    

801068ec <sys_write>:

int
sys_write(void)
{
801068ec:	55                   	push   %ebp
801068ed:	89 e5                	mov    %esp,%ebp
801068ef:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801068f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068f5:	89 44 24 08          	mov    %eax,0x8(%esp)
801068f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106900:	00 
80106901:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106908:	e8 4b fe ff ff       	call   80106758 <argfd>
8010690d:	85 c0                	test   %eax,%eax
8010690f:	78 35                	js     80106946 <sys_write+0x5a>
80106911:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106914:	89 44 24 04          	mov    %eax,0x4(%esp)
80106918:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010691f:	e8 92 fc ff ff       	call   801065b6 <argint>
80106924:	85 c0                	test   %eax,%eax
80106926:	78 1e                	js     80106946 <sys_write+0x5a>
80106928:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010692b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010692f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106932:	89 44 24 04          	mov    %eax,0x4(%esp)
80106936:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010693d:	e8 ac fc ff ff       	call   801065ee <argptr>
80106942:	85 c0                	test   %eax,%eax
80106944:	79 07                	jns    8010694d <sys_write+0x61>
    return -1;
80106946:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010694b:	eb 19                	jmp    80106966 <sys_write+0x7a>
  return filewrite(f, p, n);
8010694d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106950:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106956:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010695a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010695e:	89 04 24             	mov    %eax,(%esp)
80106961:	e8 3f a8 ff ff       	call   801011a5 <filewrite>
}
80106966:	c9                   	leave  
80106967:	c3                   	ret    

80106968 <sys_close>:

int
sys_close(void)
{
80106968:	55                   	push   %ebp
80106969:	89 e5                	mov    %esp,%ebp
8010696b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010696e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106971:	89 44 24 08          	mov    %eax,0x8(%esp)
80106975:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106978:	89 44 24 04          	mov    %eax,0x4(%esp)
8010697c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106983:	e8 d0 fd ff ff       	call   80106758 <argfd>
80106988:	85 c0                	test   %eax,%eax
8010698a:	79 07                	jns    80106993 <sys_close+0x2b>
    return -1;
8010698c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106991:	eb 24                	jmp    801069b7 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80106993:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106999:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010699c:	83 c2 08             	add    $0x8,%edx
8010699f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801069a6:	00 
  fileclose(f);
801069a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069aa:	89 04 24             	mov    %eax,(%esp)
801069ad:	e8 12 a6 ff ff       	call   80100fc4 <fileclose>
  return 0;
801069b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069b7:	c9                   	leave  
801069b8:	c3                   	ret    

801069b9 <sys_fstat>:

int
sys_fstat(void)
{
801069b9:	55                   	push   %ebp
801069ba:	89 e5                	mov    %esp,%ebp
801069bc:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801069bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801069c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801069cd:	00 
801069ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069d5:	e8 7e fd ff ff       	call   80106758 <argfd>
801069da:	85 c0                	test   %eax,%eax
801069dc:	78 1f                	js     801069fd <sys_fstat+0x44>
801069de:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801069e5:	00 
801069e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801069ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801069f4:	e8 f5 fb ff ff       	call   801065ee <argptr>
801069f9:	85 c0                	test   %eax,%eax
801069fb:	79 07                	jns    80106a04 <sys_fstat+0x4b>
    return -1;
801069fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a02:	eb 12                	jmp    80106a16 <sys_fstat+0x5d>
  return filestat(f, st);
80106a04:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a0a:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a0e:	89 04 24             	mov    %eax,(%esp)
80106a11:	e8 84 a6 ff ff       	call   8010109a <filestat>
}
80106a16:	c9                   	leave  
80106a17:	c3                   	ret    

80106a18 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106a18:	55                   	push   %ebp
80106a19:	89 e5                	mov    %esp,%ebp
80106a1b:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106a1e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106a21:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a2c:	e8 1f fc ff ff       	call   80106650 <argstr>
80106a31:	85 c0                	test   %eax,%eax
80106a33:	78 17                	js     80106a4c <sys_link+0x34>
80106a35:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106a38:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a3c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a43:	e8 08 fc ff ff       	call   80106650 <argstr>
80106a48:	85 c0                	test   %eax,%eax
80106a4a:	79 0a                	jns    80106a56 <sys_link+0x3e>
    return -1;
80106a4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a51:	e9 3c 01 00 00       	jmp    80106b92 <sys_link+0x17a>
  if((ip = namei(old)) == 0)
80106a56:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106a59:	89 04 24             	mov    %eax,(%esp)
80106a5c:	e8 a9 b9 ff ff       	call   8010240a <namei>
80106a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a68:	75 0a                	jne    80106a74 <sys_link+0x5c>
    return -1;
80106a6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6f:	e9 1e 01 00 00       	jmp    80106b92 <sys_link+0x17a>

  begin_trans();
80106a74:	e8 a4 c7 ff ff       	call   8010321d <begin_trans>

  ilock(ip);
80106a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a7c:	89 04 24             	mov    %eax,(%esp)
80106a7f:	e8 e4 ad ff ff       	call   80101868 <ilock>
  if(ip->type == T_DIR){
80106a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a87:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a8b:	66 83 f8 01          	cmp    $0x1,%ax
80106a8f:	75 1a                	jne    80106aab <sys_link+0x93>
    iunlockput(ip);
80106a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a94:	89 04 24             	mov    %eax,(%esp)
80106a97:	e8 50 b0 ff ff       	call   80101aec <iunlockput>
    commit_trans();
80106a9c:	e8 9f c7 ff ff       	call   80103240 <commit_trans>
    return -1;
80106aa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aa6:	e9 e7 00 00 00       	jmp    80106b92 <sys_link+0x17a>
  }

  ip->nlink++;
80106aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aae:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106ab2:	8d 50 01             	lea    0x1(%eax),%edx
80106ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab8:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106abf:	89 04 24             	mov    %eax,(%esp)
80106ac2:	e8 e5 ab ff ff       	call   801016ac <iupdate>
  iunlock(ip);
80106ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106aca:	89 04 24             	mov    %eax,(%esp)
80106acd:	e8 e4 ae ff ff       	call   801019b6 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80106ad2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106ad5:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106ad8:	89 54 24 04          	mov    %edx,0x4(%esp)
80106adc:	89 04 24             	mov    %eax,(%esp)
80106adf:	e8 48 b9 ff ff       	call   8010242c <nameiparent>
80106ae4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ae7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106aeb:	74 68                	je     80106b55 <sys_link+0x13d>
    goto bad;
  ilock(dp);
80106aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af0:	89 04 24             	mov    %eax,(%esp)
80106af3:	e8 70 ad ff ff       	call   80101868 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106afb:	8b 10                	mov    (%eax),%edx
80106afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b00:	8b 00                	mov    (%eax),%eax
80106b02:	39 c2                	cmp    %eax,%edx
80106b04:	75 20                	jne    80106b26 <sys_link+0x10e>
80106b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b09:	8b 40 04             	mov    0x4(%eax),%eax
80106b0c:	89 44 24 08          	mov    %eax,0x8(%esp)
80106b10:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106b13:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b1a:	89 04 24             	mov    %eax,(%esp)
80106b1d:	e8 27 b6 ff ff       	call   80102149 <dirlink>
80106b22:	85 c0                	test   %eax,%eax
80106b24:	79 0d                	jns    80106b33 <sys_link+0x11b>
    iunlockput(dp);
80106b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b29:	89 04 24             	mov    %eax,(%esp)
80106b2c:	e8 bb af ff ff       	call   80101aec <iunlockput>
    goto bad;
80106b31:	eb 23                	jmp    80106b56 <sys_link+0x13e>
  }
  iunlockput(dp);
80106b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b36:	89 04 24             	mov    %eax,(%esp)
80106b39:	e8 ae af ff ff       	call   80101aec <iunlockput>
  iput(ip);
80106b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b41:	89 04 24             	mov    %eax,(%esp)
80106b44:	e8 d2 ae ff ff       	call   80101a1b <iput>

  commit_trans();
80106b49:	e8 f2 c6 ff ff       	call   80103240 <commit_trans>

  return 0;
80106b4e:	b8 00 00 00 00       	mov    $0x0,%eax
80106b53:	eb 3d                	jmp    80106b92 <sys_link+0x17a>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106b55:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80106b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b59:	89 04 24             	mov    %eax,(%esp)
80106b5c:	e8 07 ad ff ff       	call   80101868 <ilock>
  ip->nlink--;
80106b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b64:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106b68:	8d 50 ff             	lea    -0x1(%eax),%edx
80106b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b6e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b75:	89 04 24             	mov    %eax,(%esp)
80106b78:	e8 2f ab ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
80106b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b80:	89 04 24             	mov    %eax,(%esp)
80106b83:	e8 64 af ff ff       	call   80101aec <iunlockput>
  commit_trans();
80106b88:	e8 b3 c6 ff ff       	call   80103240 <commit_trans>
  return -1;
80106b8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106b92:	c9                   	leave  
80106b93:	c3                   	ret    

80106b94 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106b94:	55                   	push   %ebp
80106b95:	89 e5                	mov    %esp,%ebp
80106b97:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106b9a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106ba1:	eb 4b                	jmp    80106bee <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106bad:	00 
80106bae:	89 44 24 08          	mov    %eax,0x8(%esp)
80106bb2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80106bbc:	89 04 24             	mov    %eax,(%esp)
80106bbf:	e8 9a b1 ff ff       	call   80101d5e <readi>
80106bc4:	83 f8 10             	cmp    $0x10,%eax
80106bc7:	74 0c                	je     80106bd5 <isdirempty+0x41>
      panic("isdirempty: readi");
80106bc9:	c7 04 24 cd 9d 10 80 	movl   $0x80109dcd,(%esp)
80106bd0:	e8 68 99 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80106bd5:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106bd9:	66 85 c0             	test   %ax,%ax
80106bdc:	74 07                	je     80106be5 <isdirempty+0x51>
      return 0;
80106bde:	b8 00 00 00 00       	mov    $0x0,%eax
80106be3:	eb 1b                	jmp    80106c00 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106be8:	83 c0 10             	add    $0x10,%eax
80106beb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106bf1:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf4:	8b 40 18             	mov    0x18(%eax),%eax
80106bf7:	39 c2                	cmp    %eax,%edx
80106bf9:	72 a8                	jb     80106ba3 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106bfb:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106c00:	c9                   	leave  
80106c01:	c3                   	ret    

80106c02 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106c02:	55                   	push   %ebp
80106c03:	89 e5                	mov    %esp,%ebp
80106c05:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106c08:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c16:	e8 35 fa ff ff       	call   80106650 <argstr>
80106c1b:	85 c0                	test   %eax,%eax
80106c1d:	79 0a                	jns    80106c29 <sys_unlink+0x27>
    return -1;
80106c1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c24:	e9 aa 01 00 00       	jmp    80106dd3 <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80106c29:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106c2c:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106c2f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c33:	89 04 24             	mov    %eax,(%esp)
80106c36:	e8 f1 b7 ff ff       	call   8010242c <nameiparent>
80106c3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c42:	75 0a                	jne    80106c4e <sys_unlink+0x4c>
    return -1;
80106c44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c49:	e9 85 01 00 00       	jmp    80106dd3 <sys_unlink+0x1d1>

  begin_trans();
80106c4e:	e8 ca c5 ff ff       	call   8010321d <begin_trans>

  ilock(dp);
80106c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c56:	89 04 24             	mov    %eax,(%esp)
80106c59:	e8 0a ac ff ff       	call   80101868 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106c5e:	c7 44 24 04 df 9d 10 	movl   $0x80109ddf,0x4(%esp)
80106c65:	80 
80106c66:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106c69:	89 04 24             	mov    %eax,(%esp)
80106c6c:	e8 ee b3 ff ff       	call   8010205f <namecmp>
80106c71:	85 c0                	test   %eax,%eax
80106c73:	0f 84 45 01 00 00    	je     80106dbe <sys_unlink+0x1bc>
80106c79:	c7 44 24 04 e1 9d 10 	movl   $0x80109de1,0x4(%esp)
80106c80:	80 
80106c81:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106c84:	89 04 24             	mov    %eax,(%esp)
80106c87:	e8 d3 b3 ff ff       	call   8010205f <namecmp>
80106c8c:	85 c0                	test   %eax,%eax
80106c8e:	0f 84 2a 01 00 00    	je     80106dbe <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106c94:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106c97:	89 44 24 08          	mov    %eax,0x8(%esp)
80106c9b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca5:	89 04 24             	mov    %eax,(%esp)
80106ca8:	e8 d4 b3 ff ff       	call   80102081 <dirlookup>
80106cad:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106cb0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cb4:	0f 84 03 01 00 00    	je     80106dbd <sys_unlink+0x1bb>
    goto bad;
  ilock(ip);
80106cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cbd:	89 04 24             	mov    %eax,(%esp)
80106cc0:	e8 a3 ab ff ff       	call   80101868 <ilock>

  if(ip->nlink < 1)
80106cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cc8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106ccc:	66 85 c0             	test   %ax,%ax
80106ccf:	7f 0c                	jg     80106cdd <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
80106cd1:	c7 04 24 e4 9d 10 80 	movl   $0x80109de4,(%esp)
80106cd8:	e8 60 98 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ce0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106ce4:	66 83 f8 01          	cmp    $0x1,%ax
80106ce8:	75 1f                	jne    80106d09 <sys_unlink+0x107>
80106cea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ced:	89 04 24             	mov    %eax,(%esp)
80106cf0:	e8 9f fe ff ff       	call   80106b94 <isdirempty>
80106cf5:	85 c0                	test   %eax,%eax
80106cf7:	75 10                	jne    80106d09 <sys_unlink+0x107>
    iunlockput(ip);
80106cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cfc:	89 04 24             	mov    %eax,(%esp)
80106cff:	e8 e8 ad ff ff       	call   80101aec <iunlockput>
    goto bad;
80106d04:	e9 b5 00 00 00       	jmp    80106dbe <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80106d09:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106d10:	00 
80106d11:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d18:	00 
80106d19:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106d1c:	89 04 24             	mov    %eax,(%esp)
80106d1f:	e8 42 f5 ff ff       	call   80106266 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106d24:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106d27:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106d2e:	00 
80106d2f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106d33:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106d36:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d3d:	89 04 24             	mov    %eax,(%esp)
80106d40:	e8 84 b1 ff ff       	call   80101ec9 <writei>
80106d45:	83 f8 10             	cmp    $0x10,%eax
80106d48:	74 0c                	je     80106d56 <sys_unlink+0x154>
    panic("unlink: writei");
80106d4a:	c7 04 24 f6 9d 10 80 	movl   $0x80109df6,(%esp)
80106d51:	e8 e7 97 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80106d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d59:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106d5d:	66 83 f8 01          	cmp    $0x1,%ax
80106d61:	75 1c                	jne    80106d7f <sys_unlink+0x17d>
    dp->nlink--;
80106d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d66:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106d6a:	8d 50 ff             	lea    -0x1(%eax),%edx
80106d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d70:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d77:	89 04 24             	mov    %eax,(%esp)
80106d7a:	e8 2d a9 ff ff       	call   801016ac <iupdate>
  }
  iunlockput(dp);
80106d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d82:	89 04 24             	mov    %eax,(%esp)
80106d85:	e8 62 ad ff ff       	call   80101aec <iunlockput>

  ip->nlink--;
80106d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d8d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106d91:	8d 50 ff             	lea    -0x1(%eax),%edx
80106d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d97:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d9e:	89 04 24             	mov    %eax,(%esp)
80106da1:	e8 06 a9 ff ff       	call   801016ac <iupdate>
  iunlockput(ip);
80106da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106da9:	89 04 24             	mov    %eax,(%esp)
80106dac:	e8 3b ad ff ff       	call   80101aec <iunlockput>

  commit_trans();
80106db1:	e8 8a c4 ff ff       	call   80103240 <commit_trans>

  return 0;
80106db6:	b8 00 00 00 00       	mov    $0x0,%eax
80106dbb:	eb 16                	jmp    80106dd3 <sys_unlink+0x1d1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106dbd:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
80106dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dc1:	89 04 24             	mov    %eax,(%esp)
80106dc4:	e8 23 ad ff ff       	call   80101aec <iunlockput>
  commit_trans();
80106dc9:	e8 72 c4 ff ff       	call   80103240 <commit_trans>
  return -1;
80106dce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106dd3:	c9                   	leave  
80106dd4:	c3                   	ret    

80106dd5 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106dd5:	55                   	push   %ebp
80106dd6:	89 e5                	mov    %esp,%ebp
80106dd8:	83 ec 48             	sub    $0x48,%esp
80106ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106dde:	8b 55 10             	mov    0x10(%ebp),%edx
80106de1:	8b 45 14             	mov    0x14(%ebp),%eax
80106de4:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106de8:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106dec:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106df0:	8d 45 de             	lea    -0x22(%ebp),%eax
80106df3:	89 44 24 04          	mov    %eax,0x4(%esp)
80106df7:	8b 45 08             	mov    0x8(%ebp),%eax
80106dfa:	89 04 24             	mov    %eax,(%esp)
80106dfd:	e8 2a b6 ff ff       	call   8010242c <nameiparent>
80106e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e09:	75 0a                	jne    80106e15 <create+0x40>
    return 0;
80106e0b:	b8 00 00 00 00       	mov    $0x0,%eax
80106e10:	e9 7e 01 00 00       	jmp    80106f93 <create+0x1be>
  ilock(dp);
80106e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e18:	89 04 24             	mov    %eax,(%esp)
80106e1b:	e8 48 aa ff ff       	call   80101868 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106e20:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106e23:	89 44 24 08          	mov    %eax,0x8(%esp)
80106e27:	8d 45 de             	lea    -0x22(%ebp),%eax
80106e2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e31:	89 04 24             	mov    %eax,(%esp)
80106e34:	e8 48 b2 ff ff       	call   80102081 <dirlookup>
80106e39:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106e3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106e40:	74 47                	je     80106e89 <create+0xb4>
    iunlockput(dp);
80106e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e45:	89 04 24             	mov    %eax,(%esp)
80106e48:	e8 9f ac ff ff       	call   80101aec <iunlockput>
    ilock(ip);
80106e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e50:	89 04 24             	mov    %eax,(%esp)
80106e53:	e8 10 aa ff ff       	call   80101868 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80106e58:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106e5d:	75 15                	jne    80106e74 <create+0x9f>
80106e5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e62:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106e66:	66 83 f8 02          	cmp    $0x2,%ax
80106e6a:	75 08                	jne    80106e74 <create+0x9f>
      return ip;
80106e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e6f:	e9 1f 01 00 00       	jmp    80106f93 <create+0x1be>
    iunlockput(ip);
80106e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e77:	89 04 24             	mov    %eax,(%esp)
80106e7a:	e8 6d ac ff ff       	call   80101aec <iunlockput>
    return 0;
80106e7f:	b8 00 00 00 00       	mov    $0x0,%eax
80106e84:	e9 0a 01 00 00       	jmp    80106f93 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106e89:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e90:	8b 00                	mov    (%eax),%eax
80106e92:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e96:	89 04 24             	mov    %eax,(%esp)
80106e99:	e8 31 a7 ff ff       	call   801015cf <ialloc>
80106e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ea1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ea5:	75 0c                	jne    80106eb3 <create+0xde>
    panic("create: ialloc");
80106ea7:	c7 04 24 05 9e 10 80 	movl   $0x80109e05,(%esp)
80106eae:	e8 8a 96 ff ff       	call   8010053d <panic>

  ilock(ip);
80106eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106eb6:	89 04 24             	mov    %eax,(%esp)
80106eb9:	e8 aa a9 ff ff       	call   80101868 <ilock>
  ip->major = major;
80106ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ec1:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106ec5:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ecc:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106ed0:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106ed4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ed7:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ee0:	89 04 24             	mov    %eax,(%esp)
80106ee3:	e8 c4 a7 ff ff       	call   801016ac <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106ee8:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106eed:	75 6a                	jne    80106f59 <create+0x184>
    dp->nlink++;  // for ".."
80106eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106ef6:	8d 50 01             	lea    0x1(%eax),%edx
80106ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106efc:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f03:	89 04 24             	mov    %eax,(%esp)
80106f06:	e8 a1 a7 ff ff       	call   801016ac <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f0e:	8b 40 04             	mov    0x4(%eax),%eax
80106f11:	89 44 24 08          	mov    %eax,0x8(%esp)
80106f15:	c7 44 24 04 df 9d 10 	movl   $0x80109ddf,0x4(%esp)
80106f1c:	80 
80106f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f20:	89 04 24             	mov    %eax,(%esp)
80106f23:	e8 21 b2 ff ff       	call   80102149 <dirlink>
80106f28:	85 c0                	test   %eax,%eax
80106f2a:	78 21                	js     80106f4d <create+0x178>
80106f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f2f:	8b 40 04             	mov    0x4(%eax),%eax
80106f32:	89 44 24 08          	mov    %eax,0x8(%esp)
80106f36:	c7 44 24 04 e1 9d 10 	movl   $0x80109de1,0x4(%esp)
80106f3d:	80 
80106f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f41:	89 04 24             	mov    %eax,(%esp)
80106f44:	e8 00 b2 ff ff       	call   80102149 <dirlink>
80106f49:	85 c0                	test   %eax,%eax
80106f4b:	79 0c                	jns    80106f59 <create+0x184>
      panic("create dots");
80106f4d:	c7 04 24 14 9e 10 80 	movl   $0x80109e14,(%esp)
80106f54:	e8 e4 95 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f5c:	8b 40 04             	mov    0x4(%eax),%eax
80106f5f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106f63:	8d 45 de             	lea    -0x22(%ebp),%eax
80106f66:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f6d:	89 04 24             	mov    %eax,(%esp)
80106f70:	e8 d4 b1 ff ff       	call   80102149 <dirlink>
80106f75:	85 c0                	test   %eax,%eax
80106f77:	79 0c                	jns    80106f85 <create+0x1b0>
    panic("create: dirlink");
80106f79:	c7 04 24 20 9e 10 80 	movl   $0x80109e20,(%esp)
80106f80:	e8 b8 95 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80106f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f88:	89 04 24             	mov    %eax,(%esp)
80106f8b:	e8 5c ab ff ff       	call   80101aec <iunlockput>

  return ip;
80106f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106f93:	c9                   	leave  
80106f94:	c3                   	ret    

80106f95 <sys_open>:

int
sys_open(void)
{
80106f95:	55                   	push   %ebp
80106f96:	89 e5                	mov    %esp,%ebp
80106f98:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106f9b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fa2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fa9:	e8 a2 f6 ff ff       	call   80106650 <argstr>
80106fae:	85 c0                	test   %eax,%eax
80106fb0:	78 17                	js     80106fc9 <sys_open+0x34>
80106fb2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106fb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fb9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106fc0:	e8 f1 f5 ff ff       	call   801065b6 <argint>
80106fc5:	85 c0                	test   %eax,%eax
80106fc7:	79 0a                	jns    80106fd3 <sys_open+0x3e>
    return -1;
80106fc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fce:	e9 46 01 00 00       	jmp    80107119 <sys_open+0x184>
  if(omode & O_CREATE){
80106fd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106fd6:	25 00 02 00 00       	and    $0x200,%eax
80106fdb:	85 c0                	test   %eax,%eax
80106fdd:	74 40                	je     8010701f <sys_open+0x8a>
    begin_trans();
80106fdf:	e8 39 c2 ff ff       	call   8010321d <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80106fe4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106fe7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106fee:	00 
80106fef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106ff6:	00 
80106ff7:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106ffe:	00 
80106fff:	89 04 24             	mov    %eax,(%esp)
80107002:	e8 ce fd ff ff       	call   80106dd5 <create>
80107007:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
8010700a:	e8 31 c2 ff ff       	call   80103240 <commit_trans>
    if(ip == 0)
8010700f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107013:	75 5c                	jne    80107071 <sys_open+0xdc>
      return -1;
80107015:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010701a:	e9 fa 00 00 00       	jmp    80107119 <sys_open+0x184>
  } else {
    if((ip = namei(path)) == 0)
8010701f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107022:	89 04 24             	mov    %eax,(%esp)
80107025:	e8 e0 b3 ff ff       	call   8010240a <namei>
8010702a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010702d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107031:	75 0a                	jne    8010703d <sys_open+0xa8>
      return -1;
80107033:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107038:	e9 dc 00 00 00       	jmp    80107119 <sys_open+0x184>
    ilock(ip);
8010703d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107040:	89 04 24             	mov    %eax,(%esp)
80107043:	e8 20 a8 ff ff       	call   80101868 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80107048:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010704b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010704f:	66 83 f8 01          	cmp    $0x1,%ax
80107053:	75 1c                	jne    80107071 <sys_open+0xdc>
80107055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107058:	85 c0                	test   %eax,%eax
8010705a:	74 15                	je     80107071 <sys_open+0xdc>
      iunlockput(ip);
8010705c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705f:	89 04 24             	mov    %eax,(%esp)
80107062:	e8 85 aa ff ff       	call   80101aec <iunlockput>
      return -1;
80107067:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010706c:	e9 a8 00 00 00       	jmp    80107119 <sys_open+0x184>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80107071:	e8 a6 9e ff ff       	call   80100f1c <filealloc>
80107076:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107079:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010707d:	74 14                	je     80107093 <sys_open+0xfe>
8010707f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107082:	89 04 24             	mov    %eax,(%esp)
80107085:	e8 43 f7 ff ff       	call   801067cd <fdalloc>
8010708a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010708d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107091:	79 23                	jns    801070b6 <sys_open+0x121>
    if(f)
80107093:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107097:	74 0b                	je     801070a4 <sys_open+0x10f>
      fileclose(f);
80107099:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010709c:	89 04 24             	mov    %eax,(%esp)
8010709f:	e8 20 9f ff ff       	call   80100fc4 <fileclose>
    iunlockput(ip);
801070a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070a7:	89 04 24             	mov    %eax,(%esp)
801070aa:	e8 3d aa ff ff       	call   80101aec <iunlockput>
    return -1;
801070af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070b4:	eb 63                	jmp    80107119 <sys_open+0x184>
  }
  iunlock(ip);
801070b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b9:	89 04 24             	mov    %eax,(%esp)
801070bc:	e8 f5 a8 ff ff       	call   801019b6 <iunlock>

  f->type = FD_INODE;
801070c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070c4:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801070ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801070d0:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801070d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070d6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801070dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070e0:	83 e0 01             	and    $0x1,%eax
801070e3:	85 c0                	test   %eax,%eax
801070e5:	0f 94 c2             	sete   %dl
801070e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070eb:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801070ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070f1:	83 e0 01             	and    $0x1,%eax
801070f4:	84 c0                	test   %al,%al
801070f6:	75 0a                	jne    80107102 <sys_open+0x16d>
801070f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070fb:	83 e0 02             	and    $0x2,%eax
801070fe:	85 c0                	test   %eax,%eax
80107100:	74 07                	je     80107109 <sys_open+0x174>
80107102:	b8 01 00 00 00       	mov    $0x1,%eax
80107107:	eb 05                	jmp    8010710e <sys_open+0x179>
80107109:	b8 00 00 00 00       	mov    $0x0,%eax
8010710e:	89 c2                	mov    %eax,%edx
80107110:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107113:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80107116:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80107119:	c9                   	leave  
8010711a:	c3                   	ret    

8010711b <sys_mkdir>:

int
sys_mkdir(void)
{
8010711b:	55                   	push   %ebp
8010711c:	89 e5                	mov    %esp,%ebp
8010711e:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80107121:	e8 f7 c0 ff ff       	call   8010321d <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80107126:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107129:	89 44 24 04          	mov    %eax,0x4(%esp)
8010712d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107134:	e8 17 f5 ff ff       	call   80106650 <argstr>
80107139:	85 c0                	test   %eax,%eax
8010713b:	78 2c                	js     80107169 <sys_mkdir+0x4e>
8010713d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107140:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80107147:	00 
80107148:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010714f:	00 
80107150:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107157:	00 
80107158:	89 04 24             	mov    %eax,(%esp)
8010715b:	e8 75 fc ff ff       	call   80106dd5 <create>
80107160:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107163:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107167:	75 0c                	jne    80107175 <sys_mkdir+0x5a>
    commit_trans();
80107169:	e8 d2 c0 ff ff       	call   80103240 <commit_trans>
    return -1;
8010716e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107173:	eb 15                	jmp    8010718a <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80107175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107178:	89 04 24             	mov    %eax,(%esp)
8010717b:	e8 6c a9 ff ff       	call   80101aec <iunlockput>
  commit_trans();
80107180:	e8 bb c0 ff ff       	call   80103240 <commit_trans>
  return 0;
80107185:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010718a:	c9                   	leave  
8010718b:	c3                   	ret    

8010718c <sys_mknod>:

int
sys_mknod(void)
{
8010718c:	55                   	push   %ebp
8010718d:	89 e5                	mov    %esp,%ebp
8010718f:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80107192:	e8 86 c0 ff ff       	call   8010321d <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80107197:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010719a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010719e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071a5:	e8 a6 f4 ff ff       	call   80106650 <argstr>
801071aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
801071ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071b1:	78 5e                	js     80107211 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
801071b3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801071b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801071ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801071c1:	e8 f0 f3 ff ff       	call   801065b6 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
801071c6:	85 c0                	test   %eax,%eax
801071c8:	78 47                	js     80107211 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801071ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801071cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801071d1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801071d8:	e8 d9 f3 ff ff       	call   801065b6 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801071dd:	85 c0                	test   %eax,%eax
801071df:	78 30                	js     80107211 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801071e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071e4:	0f bf c8             	movswl %ax,%ecx
801071e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801071ea:	0f bf d0             	movswl %ax,%edx
801071ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801071f0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801071f4:	89 54 24 08          	mov    %edx,0x8(%esp)
801071f8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801071ff:	00 
80107200:	89 04 24             	mov    %eax,(%esp)
80107203:	e8 cd fb ff ff       	call   80106dd5 <create>
80107208:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010720b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010720f:	75 0c                	jne    8010721d <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80107211:	e8 2a c0 ff ff       	call   80103240 <commit_trans>
    return -1;
80107216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010721b:	eb 15                	jmp    80107232 <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010721d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107220:	89 04 24             	mov    %eax,(%esp)
80107223:	e8 c4 a8 ff ff       	call   80101aec <iunlockput>
  commit_trans();
80107228:	e8 13 c0 ff ff       	call   80103240 <commit_trans>
  return 0;
8010722d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107232:	c9                   	leave  
80107233:	c3                   	ret    

80107234 <sys_chdir>:

int
sys_chdir(void)
{
80107234:	55                   	push   %ebp
80107235:	89 e5                	mov    %esp,%ebp
80107237:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
8010723a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010723d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107248:	e8 03 f4 ff ff       	call   80106650 <argstr>
8010724d:	85 c0                	test   %eax,%eax
8010724f:	78 14                	js     80107265 <sys_chdir+0x31>
80107251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107254:	89 04 24             	mov    %eax,(%esp)
80107257:	e8 ae b1 ff ff       	call   8010240a <namei>
8010725c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010725f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107263:	75 07                	jne    8010726c <sys_chdir+0x38>
    return -1;
80107265:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010726a:	eb 57                	jmp    801072c3 <sys_chdir+0x8f>
  ilock(ip);
8010726c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010726f:	89 04 24             	mov    %eax,(%esp)
80107272:	e8 f1 a5 ff ff       	call   80101868 <ilock>
  if(ip->type != T_DIR){
80107277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010727a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010727e:	66 83 f8 01          	cmp    $0x1,%ax
80107282:	74 12                	je     80107296 <sys_chdir+0x62>
    iunlockput(ip);
80107284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107287:	89 04 24             	mov    %eax,(%esp)
8010728a:	e8 5d a8 ff ff       	call   80101aec <iunlockput>
    return -1;
8010728f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107294:	eb 2d                	jmp    801072c3 <sys_chdir+0x8f>
  }
  iunlock(ip);
80107296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107299:	89 04 24             	mov    %eax,(%esp)
8010729c:	e8 15 a7 ff ff       	call   801019b6 <iunlock>
  iput(proc->cwd);
801072a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072a7:	8b 40 68             	mov    0x68(%eax),%eax
801072aa:	89 04 24             	mov    %eax,(%esp)
801072ad:	e8 69 a7 ff ff       	call   80101a1b <iput>
  proc->cwd = ip;
801072b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801072bb:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801072be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072c3:	c9                   	leave  
801072c4:	c3                   	ret    

801072c5 <sys_exec>:

int
sys_exec(void)
{
801072c5:	55                   	push   %ebp
801072c6:	89 e5                	mov    %esp,%ebp
801072c8:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801072ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801072d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801072d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801072dc:	e8 6f f3 ff ff       	call   80106650 <argstr>
801072e1:	85 c0                	test   %eax,%eax
801072e3:	78 1a                	js     801072ff <sys_exec+0x3a>
801072e5:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801072eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801072ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801072f6:	e8 bb f2 ff ff       	call   801065b6 <argint>
801072fb:	85 c0                	test   %eax,%eax
801072fd:	79 0a                	jns    80107309 <sys_exec+0x44>
    return -1;
801072ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107304:	e9 e2 00 00 00       	jmp    801073eb <sys_exec+0x126>
  }
  memset(argv, 0, sizeof(argv));
80107309:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80107310:	00 
80107311:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107318:	00 
80107319:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010731f:	89 04 24             	mov    %eax,(%esp)
80107322:	e8 3f ef ff ff       	call   80106266 <memset>
  for(i=0;; i++){
80107327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010732e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107331:	83 f8 1f             	cmp    $0x1f,%eax
80107334:	76 0a                	jbe    80107340 <sys_exec+0x7b>
      return -1;
80107336:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010733b:	e9 ab 00 00 00       	jmp    801073eb <sys_exec+0x126>
    if(fetchint(proc, uargv+4*i, (int*)&uarg) < 0)
80107340:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107343:	c1 e0 02             	shl    $0x2,%eax
80107346:	89 c2                	mov    %eax,%edx
80107348:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010734e:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80107351:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107357:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
8010735d:	89 54 24 08          	mov    %edx,0x8(%esp)
80107361:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80107365:	89 04 24             	mov    %eax,(%esp)
80107368:	e8 b7 f1 ff ff       	call   80106524 <fetchint>
8010736d:	85 c0                	test   %eax,%eax
8010736f:	79 07                	jns    80107378 <sys_exec+0xb3>
      return -1;
80107371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107376:	eb 73                	jmp    801073eb <sys_exec+0x126>
    if(uarg == 0){
80107378:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010737e:	85 c0                	test   %eax,%eax
80107380:	75 26                	jne    801073a8 <sys_exec+0xe3>
      argv[i] = 0;
80107382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107385:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010738c:	00 00 00 00 
      break;
80107390:	90                   	nop
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80107391:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107394:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010739a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010739e:	89 04 24             	mov    %eax,(%esp)
801073a1:	e8 56 97 ff ff       	call   80100afc <exec>
801073a6:	eb 43                	jmp    801073eb <sys_exec+0x126>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
801073a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801073b2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801073b8:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
801073bb:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
801073c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073c7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801073cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801073cf:	89 04 24             	mov    %eax,(%esp)
801073d2:	e8 81 f1 ff ff       	call   80106558 <fetchstr>
801073d7:	85 c0                	test   %eax,%eax
801073d9:	79 07                	jns    801073e2 <sys_exec+0x11d>
      return -1;
801073db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073e0:	eb 09                	jmp    801073eb <sys_exec+0x126>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801073e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(proc, uarg, &argv[i]) < 0)
      return -1;
  }
801073e6:	e9 43 ff ff ff       	jmp    8010732e <sys_exec+0x69>
  return exec(path, argv);
}
801073eb:	c9                   	leave  
801073ec:	c3                   	ret    

801073ed <sys_pipe>:

int
sys_pipe(void)
{
801073ed:	55                   	push   %ebp
801073ee:	89 e5                	mov    %esp,%ebp
801073f0:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801073f3:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801073fa:	00 
801073fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801073fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80107402:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107409:	e8 e0 f1 ff ff       	call   801065ee <argptr>
8010740e:	85 c0                	test   %eax,%eax
80107410:	79 0a                	jns    8010741c <sys_pipe+0x2f>
    return -1;
80107412:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107417:	e9 9b 00 00 00       	jmp    801074b7 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
8010741c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010741f:	89 44 24 04          	mov    %eax,0x4(%esp)
80107423:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107426:	89 04 24             	mov    %eax,(%esp)
80107429:	e8 da c7 ff ff       	call   80103c08 <pipealloc>
8010742e:	85 c0                	test   %eax,%eax
80107430:	79 07                	jns    80107439 <sys_pipe+0x4c>
    return -1;
80107432:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107437:	eb 7e                	jmp    801074b7 <sys_pipe+0xca>
  fd0 = -1;
80107439:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107440:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107443:	89 04 24             	mov    %eax,(%esp)
80107446:	e8 82 f3 ff ff       	call   801067cd <fdalloc>
8010744b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010744e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107452:	78 14                	js     80107468 <sys_pipe+0x7b>
80107454:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107457:	89 04 24             	mov    %eax,(%esp)
8010745a:	e8 6e f3 ff ff       	call   801067cd <fdalloc>
8010745f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107462:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107466:	79 37                	jns    8010749f <sys_pipe+0xb2>
    if(fd0 >= 0)
80107468:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010746c:	78 14                	js     80107482 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010746e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107474:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107477:	83 c2 08             	add    $0x8,%edx
8010747a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80107481:	00 
    fileclose(rf);
80107482:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107485:	89 04 24             	mov    %eax,(%esp)
80107488:	e8 37 9b ff ff       	call   80100fc4 <fileclose>
    fileclose(wf);
8010748d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107490:	89 04 24             	mov    %eax,(%esp)
80107493:	e8 2c 9b ff ff       	call   80100fc4 <fileclose>
    return -1;
80107498:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010749d:	eb 18                	jmp    801074b7 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010749f:	8b 45 ec             	mov    -0x14(%ebp),%eax
801074a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801074a5:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801074a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801074aa:	8d 50 04             	lea    0x4(%eax),%edx
801074ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801074b0:	89 02                	mov    %eax,(%edx)
  return 0;
801074b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801074b7:	c9                   	leave  
801074b8:	c3                   	ret    
801074b9:	00 00                	add    %al,(%eax)
	...

801074bc <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801074bc:	55                   	push   %ebp
801074bd:	89 e5                	mov    %esp,%ebp
801074bf:	83 ec 08             	sub    $0x8,%esp
  return fork();
801074c2:	e8 2c ce ff ff       	call   801042f3 <fork>
}
801074c7:	c9                   	leave  
801074c8:	c3                   	ret    

801074c9 <sys_exit>:

int
sys_exit(void)
{
801074c9:	55                   	push   %ebp
801074ca:	89 e5                	mov    %esp,%ebp
801074cc:	83 ec 08             	sub    $0x8,%esp
  exit();
801074cf:	e8 82 cf ff ff       	call   80104456 <exit>
  return 0;  // not reached
801074d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801074d9:	c9                   	leave  
801074da:	c3                   	ret    

801074db <sys_wait>:

int
sys_wait(void)
{
801074db:	55                   	push   %ebp
801074dc:	89 e5                	mov    %esp,%ebp
801074de:	83 ec 08             	sub    $0x8,%esp
  return wait();
801074e1:	e8 8b d0 ff ff       	call   80104571 <wait>
}
801074e6:	c9                   	leave  
801074e7:	c3                   	ret    

801074e8 <sys_kill>:

int
sys_kill(void)
{
801074e8:	55                   	push   %ebp
801074e9:	89 e5                	mov    %esp,%ebp
801074eb:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801074ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801074f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801074f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801074fc:	e8 b5 f0 ff ff       	call   801065b6 <argint>
80107501:	85 c0                	test   %eax,%eax
80107503:	79 07                	jns    8010750c <sys_kill+0x24>
    return -1;
80107505:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010750a:	eb 0b                	jmp    80107517 <sys_kill+0x2f>
  return kill(pid);
8010750c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010750f:	89 04 24             	mov    %eax,(%esp)
80107512:	e8 ac d5 ff ff       	call   80104ac3 <kill>
}
80107517:	c9                   	leave  
80107518:	c3                   	ret    

80107519 <sys_getpid>:

int
sys_getpid(void)
{
80107519:	55                   	push   %ebp
8010751a:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010751c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107522:	8b 40 10             	mov    0x10(%eax),%eax
}
80107525:	5d                   	pop    %ebp
80107526:	c3                   	ret    

80107527 <sys_sbrk>:

int
sys_sbrk(void)
{
80107527:	55                   	push   %ebp
80107528:	89 e5                	mov    %esp,%ebp
8010752a:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010752d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107530:	89 44 24 04          	mov    %eax,0x4(%esp)
80107534:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010753b:	e8 76 f0 ff ff       	call   801065b6 <argint>
80107540:	85 c0                	test   %eax,%eax
80107542:	79 07                	jns    8010754b <sys_sbrk+0x24>
    return -1;
80107544:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107549:	eb 24                	jmp    8010756f <sys_sbrk+0x48>
  addr = proc->sz;
8010754b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107551:	8b 00                	mov    (%eax),%eax
80107553:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107556:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107559:	89 04 24             	mov    %eax,(%esp)
8010755c:	e8 ed cc ff ff       	call   8010424e <growproc>
80107561:	85 c0                	test   %eax,%eax
80107563:	79 07                	jns    8010756c <sys_sbrk+0x45>
    return -1;
80107565:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010756a:	eb 03                	jmp    8010756f <sys_sbrk+0x48>
  return addr;
8010756c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010756f:	c9                   	leave  
80107570:	c3                   	ret    

80107571 <sys_sleep>:

int
sys_sleep(void)
{
80107571:	55                   	push   %ebp
80107572:	89 e5                	mov    %esp,%ebp
80107574:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80107577:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010757a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010757e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107585:	e8 2c f0 ff ff       	call   801065b6 <argint>
8010758a:	85 c0                	test   %eax,%eax
8010758c:	79 07                	jns    80107595 <sys_sleep+0x24>
    return -1;
8010758e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107593:	eb 6c                	jmp    80107601 <sys_sleep+0x90>
  acquire(&tickslock);
80107595:	c7 04 24 00 72 18 80 	movl   $0x80187200,(%esp)
8010759c:	e8 62 ea ff ff       	call   80106003 <acquire>
  ticks0 = ticks;
801075a1:	a1 40 7a 18 80       	mov    0x80187a40,%eax
801075a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801075a9:	eb 34                	jmp    801075df <sys_sleep+0x6e>
    if(proc->killed){
801075ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801075b1:	8b 40 24             	mov    0x24(%eax),%eax
801075b4:	85 c0                	test   %eax,%eax
801075b6:	74 13                	je     801075cb <sys_sleep+0x5a>
      release(&tickslock);
801075b8:	c7 04 24 00 72 18 80 	movl   $0x80187200,(%esp)
801075bf:	e8 b7 ea ff ff       	call   8010607b <release>
      return -1;
801075c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801075c9:	eb 36                	jmp    80107601 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801075cb:	c7 44 24 04 00 72 18 	movl   $0x80187200,0x4(%esp)
801075d2:	80 
801075d3:	c7 04 24 40 7a 18 80 	movl   $0x80187a40,(%esp)
801075da:	e8 7a d3 ff ff       	call   80104959 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801075df:	a1 40 7a 18 80       	mov    0x80187a40,%eax
801075e4:	89 c2                	mov    %eax,%edx
801075e6:	2b 55 f4             	sub    -0xc(%ebp),%edx
801075e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801075ec:	39 c2                	cmp    %eax,%edx
801075ee:	72 bb                	jb     801075ab <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801075f0:	c7 04 24 00 72 18 80 	movl   $0x80187200,(%esp)
801075f7:	e8 7f ea ff ff       	call   8010607b <release>
  return 0;
801075fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107601:	c9                   	leave  
80107602:	c3                   	ret    

80107603 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107603:	55                   	push   %ebp
80107604:	89 e5                	mov    %esp,%ebp
80107606:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80107609:	c7 04 24 00 72 18 80 	movl   $0x80187200,(%esp)
80107610:	e8 ee e9 ff ff       	call   80106003 <acquire>
  xticks = ticks;
80107615:	a1 40 7a 18 80       	mov    0x80187a40,%eax
8010761a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010761d:	c7 04 24 00 72 18 80 	movl   $0x80187200,(%esp)
80107624:	e8 52 ea ff ff       	call   8010607b <release>
  return xticks;
80107629:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010762c:	c9                   	leave  
8010762d:	c3                   	ret    

8010762e <sys_enableSwapping>:

int sys_enableSwapping(void){
8010762e:	55                   	push   %ebp
8010762f:	89 e5                	mov    %esp,%ebp
80107631:	83 ec 08             	sub    $0x8,%esp
  return enableSwapping();
80107634:	e8 15 e2 ff ff       	call   8010584e <enableSwapping>
}
80107639:	c9                   	leave  
8010763a:	c3                   	ret    

8010763b <sys_disableSwapping>:
int sys_disableSwapping(void){
8010763b:	55                   	push   %ebp
8010763c:	89 e5                	mov    %esp,%ebp
8010763e:	83 ec 08             	sub    $0x8,%esp
  return disableSwapping();
80107641:	e8 1c e2 ff ff       	call   80105862 <disableSwapping>
}
80107646:	c9                   	leave  
80107647:	c3                   	ret    

80107648 <sys_num_of_pages>:
int sys_num_of_pages(void){
80107648:	55                   	push   %ebp
80107649:	89 e5                	mov    %esp,%ebp
8010764b:	83 ec 28             	sub    $0x28,%esp
  int proc_pid;
  if(argint(0, &proc_pid) < 0)
8010764e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107651:	89 44 24 04          	mov    %eax,0x4(%esp)
80107655:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010765c:	e8 55 ef ff ff       	call   801065b6 <argint>
80107661:	85 c0                	test   %eax,%eax
80107663:	79 07                	jns    8010766c <sys_num_of_pages+0x24>
    return -1;
80107665:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010766a:	eb 0b                	jmp    80107677 <sys_num_of_pages+0x2f>
  return num_of_pages(proc_pid);
8010766c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766f:	89 04 24             	mov    %eax,(%esp)
80107672:	e8 ff e1 ff ff       	call   80105876 <num_of_pages>
}
80107677:	c9                   	leave  
80107678:	c3                   	ret    

80107679 <sys_shmget>:

int sys_shmget(void){
80107679:	55                   	push   %ebp
8010767a:	89 e5                	mov    %esp,%ebp
8010767c:	83 ec 28             	sub    $0x28,%esp
 int key;
 int size;
 int shmflg;
 
 if(argint(0, &key) < 0)
8010767f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107682:	89 44 24 04          	mov    %eax,0x4(%esp)
80107686:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010768d:	e8 24 ef ff ff       	call   801065b6 <argint>
80107692:	85 c0                	test   %eax,%eax
80107694:	79 07                	jns    8010769d <sys_shmget+0x24>
    return -1;
80107696:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010769b:	eb 57                	jmp    801076f4 <sys_shmget+0x7b>
 if(argint(1, &size) < 0)
8010769d:	8d 45 f0             	lea    -0x10(%ebp),%eax
801076a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801076a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801076ab:	e8 06 ef ff ff       	call   801065b6 <argint>
801076b0:	85 c0                	test   %eax,%eax
801076b2:	79 07                	jns    801076bb <sys_shmget+0x42>
    return -1;
801076b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801076b9:	eb 39                	jmp    801076f4 <sys_shmget+0x7b>
 if(argint(2, &shmflg) < 0)
801076bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801076be:	89 44 24 04          	mov    %eax,0x4(%esp)
801076c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801076c9:	e8 e8 ee ff ff       	call   801065b6 <argint>
801076ce:	85 c0                	test   %eax,%eax
801076d0:	79 07                	jns    801076d9 <sys_shmget+0x60>
    return -1;
801076d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801076d7:	eb 1b                	jmp    801076f4 <sys_shmget+0x7b>
 
 return shmget(key,size,shmflg);
801076d9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801076dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801076df:	89 c2                	mov    %eax,%edx
801076e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801076e8:	89 54 24 04          	mov    %edx,0x4(%esp)
801076ec:	89 04 24             	mov    %eax,(%esp)
801076ef:	e8 6d e2 ff ff       	call   80105961 <shmget>
}
801076f4:	c9                   	leave  
801076f5:	c3                   	ret    

801076f6 <sys_shmdel>:

int sys_shmdel(void){
801076f6:	55                   	push   %ebp
801076f7:	89 e5                	mov    %esp,%ebp
801076f9:	83 ec 28             	sub    $0x28,%esp
  int shmid;
  if(argint(0, &shmid) < 0)
801076fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801076ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80107703:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010770a:	e8 a7 ee ff ff       	call   801065b6 <argint>
8010770f:	85 c0                	test   %eax,%eax
80107711:	79 07                	jns    8010771a <sys_shmdel+0x24>
    return -1;
80107713:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107718:	eb 0b                	jmp    80107725 <sys_shmdel+0x2f>
  return shmdel(shmid);
8010771a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771d:	89 04 24             	mov    %eax,(%esp)
80107720:	e8 f6 e3 ff ff       	call   80105b1b <shmdel>
}
80107725:	c9                   	leave  
80107726:	c3                   	ret    

80107727 <sys_shmat>:


void* sys_shmat(void){
80107727:	55                   	push   %ebp
80107728:	89 e5                	mov    %esp,%ebp
8010772a:	83 ec 28             	sub    $0x28,%esp
 void *shmat(int shmid, int shmflg);
 int shmid;
 int shmflg;
  if(argint(0, &shmid) < 0)
8010772d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107730:	89 44 24 04          	mov    %eax,0x4(%esp)
80107734:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010773b:	e8 76 ee ff ff       	call   801065b6 <argint>
80107740:	85 c0                	test   %eax,%eax
80107742:	79 07                	jns    8010774b <sys_shmat+0x24>
    return (void*)-1;
80107744:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107749:	eb 30                	jmp    8010777b <sys_shmat+0x54>
   if(argint(1, &shmflg) < 0)
8010774b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010774e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107752:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107759:	e8 58 ee ff ff       	call   801065b6 <argint>
8010775e:	85 c0                	test   %eax,%eax
80107760:	79 07                	jns    80107769 <sys_shmat+0x42>
    return (void*)-1;
80107762:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107767:	eb 12                	jmp    8010777b <sys_shmat+0x54>
 
   
 return shmat(shmid,shmflg);
80107769:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010776c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776f:	89 54 24 04          	mov    %edx,0x4(%esp)
80107773:	89 04 24             	mov    %eax,(%esp)
80107776:	e8 aa e4 ff ff       	call   80105c25 <shmat>
  
}
8010777b:	c9                   	leave  
8010777c:	c3                   	ret    

8010777d <sys_shmdt>:

int sys_shmdt(void){
8010777d:	55                   	push   %ebp
8010777e:	89 e5                	mov    %esp,%ebp
80107780:	83 ec 28             	sub    $0x28,%esp
   void *shmaddr;
   if(argptr(0, (void*)&shmaddr,sizeof(void*)) < 0){
80107783:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010778a:	00 
8010778b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010778e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107792:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107799:	e8 50 ee ff ff       	call   801065ee <argptr>
8010779e:	85 c0                	test   %eax,%eax
801077a0:	79 07                	jns    801077a9 <sys_shmdt+0x2c>
     return -1;
801077a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077a7:	eb 0b                	jmp    801077b4 <sys_shmdt+0x37>
   }
   return shmdt(shmaddr);
801077a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ac:	89 04 24             	mov    %eax,(%esp)
801077af:	e8 83 e6 ff ff       	call   80105e37 <shmdt>
}
801077b4:	c9                   	leave  
801077b5:	c3                   	ret    

801077b6 <sys_get_share_memory_address>:

void* sys_get_share_memory_address(void){
801077b6:	55                   	push   %ebp
801077b7:	89 e5                	mov    %esp,%ebp
801077b9:	83 ec 28             	sub    $0x28,%esp
  int key;
  if(argint(0, &key) < 0)
801077bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
801077bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801077c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801077ca:	e8 e7 ed ff ff       	call   801065b6 <argint>
801077cf:	85 c0                	test   %eax,%eax
801077d1:	79 07                	jns    801077da <sys_get_share_memory_address+0x24>
    return (void*)-1;
801077d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077d8:	eb 0b                	jmp    801077e5 <sys_get_share_memory_address+0x2f>
  return get_share_memory_address(key);
801077da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077dd:	89 04 24             	mov    %eax,(%esp)
801077e0:	e8 78 e7 ff ff       	call   80105f5d <get_share_memory_address>
801077e5:	c9                   	leave  
801077e6:	c3                   	ret    
	...

801077e8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801077e8:	55                   	push   %ebp
801077e9:	89 e5                	mov    %esp,%ebp
801077eb:	83 ec 08             	sub    $0x8,%esp
801077ee:	8b 55 08             	mov    0x8(%ebp),%edx
801077f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801077f4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801077f8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801077fb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801077ff:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107803:	ee                   	out    %al,(%dx)
}
80107804:	c9                   	leave  
80107805:	c3                   	ret    

80107806 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80107806:	55                   	push   %ebp
80107807:	89 e5                	mov    %esp,%ebp
80107809:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010780c:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80107813:	00 
80107814:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010781b:	e8 c8 ff ff ff       	call   801077e8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80107820:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80107827:	00 
80107828:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010782f:	e8 b4 ff ff ff       	call   801077e8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80107834:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010783b:	00 
8010783c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80107843:	e8 a0 ff ff ff       	call   801077e8 <outb>
  picenable(IRQ_TIMER);
80107848:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010784f:	e8 3d c2 ff ff       	call   80103a91 <picenable>
}
80107854:	c9                   	leave  
80107855:	c3                   	ret    
	...

80107858 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107858:	1e                   	push   %ds
  pushl %es
80107859:	06                   	push   %es
  pushl %fs
8010785a:	0f a0                	push   %fs
  pushl %gs
8010785c:	0f a8                	push   %gs
  pushal
8010785e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010785f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107863:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107865:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107867:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010786b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010786d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010786f:	54                   	push   %esp
  call trap
80107870:	e8 de 01 00 00       	call   80107a53 <trap>
  addl $4, %esp
80107875:	83 c4 04             	add    $0x4,%esp

80107878 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107878:	61                   	popa   
  popl %gs
80107879:	0f a9                	pop    %gs
  popl %fs
8010787b:	0f a1                	pop    %fs
  popl %es
8010787d:	07                   	pop    %es
  popl %ds
8010787e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010787f:	83 c4 08             	add    $0x8,%esp
  iret
80107882:	cf                   	iret   
	...

80107884 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107884:	55                   	push   %ebp
80107885:	89 e5                	mov    %esp,%ebp
80107887:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010788a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010788d:	83 e8 01             	sub    $0x1,%eax
80107890:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107894:	8b 45 08             	mov    0x8(%ebp),%eax
80107897:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010789b:	8b 45 08             	mov    0x8(%ebp),%eax
8010789e:	c1 e8 10             	shr    $0x10,%eax
801078a1:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801078a5:	8d 45 fa             	lea    -0x6(%ebp),%eax
801078a8:	0f 01 18             	lidtl  (%eax)
}
801078ab:	c9                   	leave  
801078ac:	c3                   	ret    

801078ad <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801078ad:	55                   	push   %ebp
801078ae:	89 e5                	mov    %esp,%ebp
801078b0:	53                   	push   %ebx
801078b1:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801078b4:	0f 20 d3             	mov    %cr2,%ebx
801078b7:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
801078ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801078bd:	83 c4 10             	add    $0x10,%esp
801078c0:	5b                   	pop    %ebx
801078c1:	5d                   	pop    %ebp
801078c2:	c3                   	ret    

801078c3 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801078c3:	55                   	push   %ebp
801078c4:	89 e5                	mov    %esp,%ebp
801078c6:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801078c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078d0:	e9 c3 00 00 00       	jmp    80107998 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801078d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d8:	8b 04 85 f8 d0 10 80 	mov    -0x7fef2f08(,%eax,4),%eax
801078df:	89 c2                	mov    %eax,%edx
801078e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e4:	66 89 14 c5 40 72 18 	mov    %dx,-0x7fe78dc0(,%eax,8)
801078eb:	80 
801078ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ef:	66 c7 04 c5 42 72 18 	movw   $0x8,-0x7fe78dbe(,%eax,8)
801078f6:	80 08 00 
801078f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fc:	0f b6 14 c5 44 72 18 	movzbl -0x7fe78dbc(,%eax,8),%edx
80107903:	80 
80107904:	83 e2 e0             	and    $0xffffffe0,%edx
80107907:	88 14 c5 44 72 18 80 	mov    %dl,-0x7fe78dbc(,%eax,8)
8010790e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107911:	0f b6 14 c5 44 72 18 	movzbl -0x7fe78dbc(,%eax,8),%edx
80107918:	80 
80107919:	83 e2 1f             	and    $0x1f,%edx
8010791c:	88 14 c5 44 72 18 80 	mov    %dl,-0x7fe78dbc(,%eax,8)
80107923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107926:	0f b6 14 c5 45 72 18 	movzbl -0x7fe78dbb(,%eax,8),%edx
8010792d:	80 
8010792e:	83 e2 f0             	and    $0xfffffff0,%edx
80107931:	83 ca 0e             	or     $0xe,%edx
80107934:	88 14 c5 45 72 18 80 	mov    %dl,-0x7fe78dbb(,%eax,8)
8010793b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793e:	0f b6 14 c5 45 72 18 	movzbl -0x7fe78dbb(,%eax,8),%edx
80107945:	80 
80107946:	83 e2 ef             	and    $0xffffffef,%edx
80107949:	88 14 c5 45 72 18 80 	mov    %dl,-0x7fe78dbb(,%eax,8)
80107950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107953:	0f b6 14 c5 45 72 18 	movzbl -0x7fe78dbb(,%eax,8),%edx
8010795a:	80 
8010795b:	83 e2 9f             	and    $0xffffff9f,%edx
8010795e:	88 14 c5 45 72 18 80 	mov    %dl,-0x7fe78dbb(,%eax,8)
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	0f b6 14 c5 45 72 18 	movzbl -0x7fe78dbb(,%eax,8),%edx
8010796f:	80 
80107970:	83 ca 80             	or     $0xffffff80,%edx
80107973:	88 14 c5 45 72 18 80 	mov    %dl,-0x7fe78dbb(,%eax,8)
8010797a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797d:	8b 04 85 f8 d0 10 80 	mov    -0x7fef2f08(,%eax,4),%eax
80107984:	c1 e8 10             	shr    $0x10,%eax
80107987:	89 c2                	mov    %eax,%edx
80107989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798c:	66 89 14 c5 46 72 18 	mov    %dx,-0x7fe78dba(,%eax,8)
80107993:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107994:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107998:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010799f:	0f 8e 30 ff ff ff    	jle    801078d5 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801079a5:	a1 f8 d1 10 80       	mov    0x8010d1f8,%eax
801079aa:	66 a3 40 74 18 80    	mov    %ax,0x80187440
801079b0:	66 c7 05 42 74 18 80 	movw   $0x8,0x80187442
801079b7:	08 00 
801079b9:	0f b6 05 44 74 18 80 	movzbl 0x80187444,%eax
801079c0:	83 e0 e0             	and    $0xffffffe0,%eax
801079c3:	a2 44 74 18 80       	mov    %al,0x80187444
801079c8:	0f b6 05 44 74 18 80 	movzbl 0x80187444,%eax
801079cf:	83 e0 1f             	and    $0x1f,%eax
801079d2:	a2 44 74 18 80       	mov    %al,0x80187444
801079d7:	0f b6 05 45 74 18 80 	movzbl 0x80187445,%eax
801079de:	83 c8 0f             	or     $0xf,%eax
801079e1:	a2 45 74 18 80       	mov    %al,0x80187445
801079e6:	0f b6 05 45 74 18 80 	movzbl 0x80187445,%eax
801079ed:	83 e0 ef             	and    $0xffffffef,%eax
801079f0:	a2 45 74 18 80       	mov    %al,0x80187445
801079f5:	0f b6 05 45 74 18 80 	movzbl 0x80187445,%eax
801079fc:	83 c8 60             	or     $0x60,%eax
801079ff:	a2 45 74 18 80       	mov    %al,0x80187445
80107a04:	0f b6 05 45 74 18 80 	movzbl 0x80187445,%eax
80107a0b:	83 c8 80             	or     $0xffffff80,%eax
80107a0e:	a2 45 74 18 80       	mov    %al,0x80187445
80107a13:	a1 f8 d1 10 80       	mov    0x8010d1f8,%eax
80107a18:	c1 e8 10             	shr    $0x10,%eax
80107a1b:	66 a3 46 74 18 80    	mov    %ax,0x80187446
  
  initlock(&tickslock, "time");
80107a21:	c7 44 24 04 30 9e 10 	movl   $0x80109e30,0x4(%esp)
80107a28:	80 
80107a29:	c7 04 24 00 72 18 80 	movl   $0x80187200,(%esp)
80107a30:	e8 ad e5 ff ff       	call   80105fe2 <initlock>
}
80107a35:	c9                   	leave  
80107a36:	c3                   	ret    

80107a37 <idtinit>:

void
idtinit(void)
{
80107a37:	55                   	push   %ebp
80107a38:	89 e5                	mov    %esp,%ebp
80107a3a:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80107a3d:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80107a44:	00 
80107a45:	c7 04 24 40 72 18 80 	movl   $0x80187240,(%esp)
80107a4c:	e8 33 fe ff ff       	call   80107884 <lidt>
}
80107a51:	c9                   	leave  
80107a52:	c3                   	ret    

80107a53 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107a53:	55                   	push   %ebp
80107a54:	89 e5                	mov    %esp,%ebp
80107a56:	57                   	push   %edi
80107a57:	56                   	push   %esi
80107a58:	53                   	push   %ebx
80107a59:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80107a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80107a5f:	8b 40 30             	mov    0x30(%eax),%eax
80107a62:	83 f8 40             	cmp    $0x40,%eax
80107a65:	75 3e                	jne    80107aa5 <trap+0x52>
    if(proc->killed)
80107a67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a6d:	8b 40 24             	mov    0x24(%eax),%eax
80107a70:	85 c0                	test   %eax,%eax
80107a72:	74 05                	je     80107a79 <trap+0x26>
      exit();
80107a74:	e8 dd c9 ff ff       	call   80104456 <exit>
    proc->tf = tf;
80107a79:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a7f:	8b 55 08             	mov    0x8(%ebp),%edx
80107a82:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107a85:	e8 09 ec ff ff       	call   80106693 <syscall>
    if(proc->killed)
80107a8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107a90:	8b 40 24             	mov    0x24(%eax),%eax
80107a93:	85 c0                	test   %eax,%eax
80107a95:	0f 84 34 02 00 00    	je     80107ccf <trap+0x27c>
      exit();
80107a9b:	e8 b6 c9 ff ff       	call   80104456 <exit>
    return;
80107aa0:	e9 2a 02 00 00       	jmp    80107ccf <trap+0x27c>
  }

  switch(tf->trapno){
80107aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80107aa8:	8b 40 30             	mov    0x30(%eax),%eax
80107aab:	83 e8 20             	sub    $0x20,%eax
80107aae:	83 f8 1f             	cmp    $0x1f,%eax
80107ab1:	0f 87 bc 00 00 00    	ja     80107b73 <trap+0x120>
80107ab7:	8b 04 85 d8 9e 10 80 	mov    -0x7fef6128(,%eax,4),%eax
80107abe:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107ac0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ac6:	0f b6 00             	movzbl (%eax),%eax
80107ac9:	84 c0                	test   %al,%al
80107acb:	75 31                	jne    80107afe <trap+0xab>
      acquire(&tickslock);
80107acd:	c7 04 24 00 72 18 80 	movl   $0x80187200,(%esp)
80107ad4:	e8 2a e5 ff ff       	call   80106003 <acquire>
      ticks++;
80107ad9:	a1 40 7a 18 80       	mov    0x80187a40,%eax
80107ade:	83 c0 01             	add    $0x1,%eax
80107ae1:	a3 40 7a 18 80       	mov    %eax,0x80187a40
      wakeup(&ticks);
80107ae6:	c7 04 24 40 7a 18 80 	movl   $0x80187a40,(%esp)
80107aed:	e8 a6 cf ff ff       	call   80104a98 <wakeup>
      release(&tickslock);
80107af2:	c7 04 24 00 72 18 80 	movl   $0x80187200,(%esp)
80107af9:	e8 7d e5 ff ff       	call   8010607b <release>
    }
    lapiceoi();
80107afe:	e8 da b3 ff ff       	call   80102edd <lapiceoi>
    break;
80107b03:	e9 41 01 00 00       	jmp    80107c49 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80107b08:	e8 f0 ab ff ff       	call   801026fd <ideintr>
    lapiceoi();
80107b0d:	e8 cb b3 ff ff       	call   80102edd <lapiceoi>
    break;
80107b12:	e9 32 01 00 00       	jmp    80107c49 <trap+0x1f6>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80107b17:	e8 9f b1 ff ff       	call   80102cbb <kbdintr>
    lapiceoi();
80107b1c:	e8 bc b3 ff ff       	call   80102edd <lapiceoi>
    break;
80107b21:	e9 23 01 00 00       	jmp    80107c49 <trap+0x1f6>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107b26:	e8 a9 03 00 00       	call   80107ed4 <uartintr>
    lapiceoi();
80107b2b:	e8 ad b3 ff ff       	call   80102edd <lapiceoi>
    break;
80107b30:	e9 14 01 00 00       	jmp    80107c49 <trap+0x1f6>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80107b35:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107b38:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80107b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80107b3e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107b42:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107b45:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b4b:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107b4e:	0f b6 c0             	movzbl %al,%eax
80107b51:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80107b55:	89 54 24 08          	mov    %edx,0x8(%esp)
80107b59:	89 44 24 04          	mov    %eax,0x4(%esp)
80107b5d:	c7 04 24 38 9e 10 80 	movl   $0x80109e38,(%esp)
80107b64:	e8 38 88 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80107b69:	e8 6f b3 ff ff       	call   80102edd <lapiceoi>
    break;
80107b6e:	e9 d6 00 00 00       	jmp    80107c49 <trap+0x1f6>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107b73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107b79:	85 c0                	test   %eax,%eax
80107b7b:	74 11                	je     80107b8e <trap+0x13b>
80107b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80107b80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107b84:	0f b7 c0             	movzwl %ax,%eax
80107b87:	83 e0 03             	and    $0x3,%eax
80107b8a:	85 c0                	test   %eax,%eax
80107b8c:	75 46                	jne    80107bd4 <trap+0x181>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107b8e:	e8 1a fd ff ff       	call   801078ad <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80107b93:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107b96:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107b99:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107ba0:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107ba3:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80107ba6:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107ba9:	8b 52 30             	mov    0x30(%edx),%edx
80107bac:	89 44 24 10          	mov    %eax,0x10(%esp)
80107bb0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80107bb4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80107bb8:	89 54 24 04          	mov    %edx,0x4(%esp)
80107bbc:	c7 04 24 5c 9e 10 80 	movl   $0x80109e5c,(%esp)
80107bc3:	e8 d9 87 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107bc8:	c7 04 24 8e 9e 10 80 	movl   $0x80109e8e,(%esp)
80107bcf:	e8 69 89 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107bd4:	e8 d4 fc ff ff       	call   801078ad <rcr2>
80107bd9:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107bdb:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107bde:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107be1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107be7:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107bea:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107bed:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107bf0:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107bf3:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107bf6:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107bf9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107bff:	83 c0 6c             	add    $0x6c,%eax
80107c02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107c05:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107c0b:	8b 40 10             	mov    0x10(%eax),%eax
80107c0e:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80107c12:	89 7c 24 18          	mov    %edi,0x18(%esp)
80107c16:	89 74 24 14          	mov    %esi,0x14(%esp)
80107c1a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107c1e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80107c22:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107c25:	89 54 24 08          	mov    %edx,0x8(%esp)
80107c29:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c2d:	c7 04 24 94 9e 10 80 	movl   $0x80109e94,(%esp)
80107c34:	e8 68 87 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107c39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c3f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107c46:	eb 01                	jmp    80107c49 <trap+0x1f6>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107c48:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107c49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c4f:	85 c0                	test   %eax,%eax
80107c51:	74 24                	je     80107c77 <trap+0x224>
80107c53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c59:	8b 40 24             	mov    0x24(%eax),%eax
80107c5c:	85 c0                	test   %eax,%eax
80107c5e:	74 17                	je     80107c77 <trap+0x224>
80107c60:	8b 45 08             	mov    0x8(%ebp),%eax
80107c63:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107c67:	0f b7 c0             	movzwl %ax,%eax
80107c6a:	83 e0 03             	and    $0x3,%eax
80107c6d:	83 f8 03             	cmp    $0x3,%eax
80107c70:	75 05                	jne    80107c77 <trap+0x224>
    exit();
80107c72:	e8 df c7 ff ff       	call   80104456 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80107c77:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c7d:	85 c0                	test   %eax,%eax
80107c7f:	74 1e                	je     80107c9f <trap+0x24c>
80107c81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107c87:	8b 40 0c             	mov    0xc(%eax),%eax
80107c8a:	83 f8 04             	cmp    $0x4,%eax
80107c8d:	75 10                	jne    80107c9f <trap+0x24c>
80107c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80107c92:	8b 40 30             	mov    0x30(%eax),%eax
80107c95:	83 f8 20             	cmp    $0x20,%eax
80107c98:	75 05                	jne    80107c9f <trap+0x24c>
    yield();
80107c9a:	e8 5c cc ff ff       	call   801048fb <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107c9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107ca5:	85 c0                	test   %eax,%eax
80107ca7:	74 27                	je     80107cd0 <trap+0x27d>
80107ca9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107caf:	8b 40 24             	mov    0x24(%eax),%eax
80107cb2:	85 c0                	test   %eax,%eax
80107cb4:	74 1a                	je     80107cd0 <trap+0x27d>
80107cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80107cb9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107cbd:	0f b7 c0             	movzwl %ax,%eax
80107cc0:	83 e0 03             	and    $0x3,%eax
80107cc3:	83 f8 03             	cmp    $0x3,%eax
80107cc6:	75 08                	jne    80107cd0 <trap+0x27d>
    exit();
80107cc8:	e8 89 c7 ff ff       	call   80104456 <exit>
80107ccd:	eb 01                	jmp    80107cd0 <trap+0x27d>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107ccf:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107cd0:	83 c4 3c             	add    $0x3c,%esp
80107cd3:	5b                   	pop    %ebx
80107cd4:	5e                   	pop    %esi
80107cd5:	5f                   	pop    %edi
80107cd6:	5d                   	pop    %ebp
80107cd7:	c3                   	ret    

80107cd8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107cd8:	55                   	push   %ebp
80107cd9:	89 e5                	mov    %esp,%ebp
80107cdb:	53                   	push   %ebx
80107cdc:	83 ec 14             	sub    $0x14,%esp
80107cdf:	8b 45 08             	mov    0x8(%ebp),%eax
80107ce2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107ce6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80107cea:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80107cee:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80107cf2:	ec                   	in     (%dx),%al
80107cf3:	89 c3                	mov    %eax,%ebx
80107cf5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80107cf8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80107cfc:	83 c4 14             	add    $0x14,%esp
80107cff:	5b                   	pop    %ebx
80107d00:	5d                   	pop    %ebp
80107d01:	c3                   	ret    

80107d02 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107d02:	55                   	push   %ebp
80107d03:	89 e5                	mov    %esp,%ebp
80107d05:	83 ec 08             	sub    $0x8,%esp
80107d08:	8b 55 08             	mov    0x8(%ebp),%edx
80107d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d0e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107d12:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107d15:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107d19:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107d1d:	ee                   	out    %al,(%dx)
}
80107d1e:	c9                   	leave  
80107d1f:	c3                   	ret    

80107d20 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107d20:	55                   	push   %ebp
80107d21:	89 e5                	mov    %esp,%ebp
80107d23:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107d26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107d2d:	00 
80107d2e:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107d35:	e8 c8 ff ff ff       	call   80107d02 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107d3a:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107d41:	00 
80107d42:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107d49:	e8 b4 ff ff ff       	call   80107d02 <outb>
  outb(COM1+0, 115200/9600);
80107d4e:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107d55:	00 
80107d56:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107d5d:	e8 a0 ff ff ff       	call   80107d02 <outb>
  outb(COM1+1, 0);
80107d62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107d69:	00 
80107d6a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107d71:	e8 8c ff ff ff       	call   80107d02 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107d76:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107d7d:	00 
80107d7e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107d85:	e8 78 ff ff ff       	call   80107d02 <outb>
  outb(COM1+4, 0);
80107d8a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107d91:	00 
80107d92:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107d99:	e8 64 ff ff ff       	call   80107d02 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107d9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107da5:	00 
80107da6:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107dad:	e8 50 ff ff ff       	call   80107d02 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107db2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107db9:	e8 1a ff ff ff       	call   80107cd8 <inb>
80107dbe:	3c ff                	cmp    $0xff,%al
80107dc0:	74 6c                	je     80107e2e <uartinit+0x10e>
    return;
  uart = 1;
80107dc2:	c7 05 b0 d6 10 80 01 	movl   $0x1,0x8010d6b0
80107dc9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107dcc:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107dd3:	e8 00 ff ff ff       	call   80107cd8 <inb>
  inb(COM1+0);
80107dd8:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107ddf:	e8 f4 fe ff ff       	call   80107cd8 <inb>
  picenable(IRQ_COM1);
80107de4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107deb:	e8 a1 bc ff ff       	call   80103a91 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107df0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107df7:	00 
80107df8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107dff:	e8 66 ab ff ff       	call   8010296a <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107e04:	c7 45 f4 58 9f 10 80 	movl   $0x80109f58,-0xc(%ebp)
80107e0b:	eb 15                	jmp    80107e22 <uartinit+0x102>
    uartputc(*p);
80107e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e10:	0f b6 00             	movzbl (%eax),%eax
80107e13:	0f be c0             	movsbl %al,%eax
80107e16:	89 04 24             	mov    %eax,(%esp)
80107e19:	e8 13 00 00 00       	call   80107e31 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107e1e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	0f b6 00             	movzbl (%eax),%eax
80107e28:	84 c0                	test   %al,%al
80107e2a:	75 e1                	jne    80107e0d <uartinit+0xed>
80107e2c:	eb 01                	jmp    80107e2f <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107e2e:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107e2f:	c9                   	leave  
80107e30:	c3                   	ret    

80107e31 <uartputc>:

void
uartputc(int c)
{
80107e31:	55                   	push   %ebp
80107e32:	89 e5                	mov    %esp,%ebp
80107e34:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107e37:	a1 b0 d6 10 80       	mov    0x8010d6b0,%eax
80107e3c:	85 c0                	test   %eax,%eax
80107e3e:	74 4d                	je     80107e8d <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107e40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e47:	eb 10                	jmp    80107e59 <uartputc+0x28>
    microdelay(10);
80107e49:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107e50:	e8 ad b0 ff ff       	call   80102f02 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107e55:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e59:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107e5d:	7f 16                	jg     80107e75 <uartputc+0x44>
80107e5f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107e66:	e8 6d fe ff ff       	call   80107cd8 <inb>
80107e6b:	0f b6 c0             	movzbl %al,%eax
80107e6e:	83 e0 20             	and    $0x20,%eax
80107e71:	85 c0                	test   %eax,%eax
80107e73:	74 d4                	je     80107e49 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107e75:	8b 45 08             	mov    0x8(%ebp),%eax
80107e78:	0f b6 c0             	movzbl %al,%eax
80107e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e7f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107e86:	e8 77 fe ff ff       	call   80107d02 <outb>
80107e8b:	eb 01                	jmp    80107e8e <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107e8d:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107e8e:	c9                   	leave  
80107e8f:	c3                   	ret    

80107e90 <uartgetc>:

static int
uartgetc(void)
{
80107e90:	55                   	push   %ebp
80107e91:	89 e5                	mov    %esp,%ebp
80107e93:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107e96:	a1 b0 d6 10 80       	mov    0x8010d6b0,%eax
80107e9b:	85 c0                	test   %eax,%eax
80107e9d:	75 07                	jne    80107ea6 <uartgetc+0x16>
    return -1;
80107e9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ea4:	eb 2c                	jmp    80107ed2 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107ea6:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107ead:	e8 26 fe ff ff       	call   80107cd8 <inb>
80107eb2:	0f b6 c0             	movzbl %al,%eax
80107eb5:	83 e0 01             	and    $0x1,%eax
80107eb8:	85 c0                	test   %eax,%eax
80107eba:	75 07                	jne    80107ec3 <uartgetc+0x33>
    return -1;
80107ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ec1:	eb 0f                	jmp    80107ed2 <uartgetc+0x42>
  return inb(COM1+0);
80107ec3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107eca:	e8 09 fe ff ff       	call   80107cd8 <inb>
80107ecf:	0f b6 c0             	movzbl %al,%eax
}
80107ed2:	c9                   	leave  
80107ed3:	c3                   	ret    

80107ed4 <uartintr>:

void
uartintr(void)
{
80107ed4:	55                   	push   %ebp
80107ed5:	89 e5                	mov    %esp,%ebp
80107ed7:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107eda:	c7 04 24 90 7e 10 80 	movl   $0x80107e90,(%esp)
80107ee1:	e8 c7 88 ff ff       	call   801007ad <consoleintr>
}
80107ee6:	c9                   	leave  
80107ee7:	c3                   	ret    

80107ee8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107ee8:	6a 00                	push   $0x0
  pushl $0
80107eea:	6a 00                	push   $0x0
  jmp alltraps
80107eec:	e9 67 f9 ff ff       	jmp    80107858 <alltraps>

80107ef1 <vector1>:
.globl vector1
vector1:
  pushl $0
80107ef1:	6a 00                	push   $0x0
  pushl $1
80107ef3:	6a 01                	push   $0x1
  jmp alltraps
80107ef5:	e9 5e f9 ff ff       	jmp    80107858 <alltraps>

80107efa <vector2>:
.globl vector2
vector2:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $2
80107efc:	6a 02                	push   $0x2
  jmp alltraps
80107efe:	e9 55 f9 ff ff       	jmp    80107858 <alltraps>

80107f03 <vector3>:
.globl vector3
vector3:
  pushl $0
80107f03:	6a 00                	push   $0x0
  pushl $3
80107f05:	6a 03                	push   $0x3
  jmp alltraps
80107f07:	e9 4c f9 ff ff       	jmp    80107858 <alltraps>

80107f0c <vector4>:
.globl vector4
vector4:
  pushl $0
80107f0c:	6a 00                	push   $0x0
  pushl $4
80107f0e:	6a 04                	push   $0x4
  jmp alltraps
80107f10:	e9 43 f9 ff ff       	jmp    80107858 <alltraps>

80107f15 <vector5>:
.globl vector5
vector5:
  pushl $0
80107f15:	6a 00                	push   $0x0
  pushl $5
80107f17:	6a 05                	push   $0x5
  jmp alltraps
80107f19:	e9 3a f9 ff ff       	jmp    80107858 <alltraps>

80107f1e <vector6>:
.globl vector6
vector6:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $6
80107f20:	6a 06                	push   $0x6
  jmp alltraps
80107f22:	e9 31 f9 ff ff       	jmp    80107858 <alltraps>

80107f27 <vector7>:
.globl vector7
vector7:
  pushl $0
80107f27:	6a 00                	push   $0x0
  pushl $7
80107f29:	6a 07                	push   $0x7
  jmp alltraps
80107f2b:	e9 28 f9 ff ff       	jmp    80107858 <alltraps>

80107f30 <vector8>:
.globl vector8
vector8:
  pushl $8
80107f30:	6a 08                	push   $0x8
  jmp alltraps
80107f32:	e9 21 f9 ff ff       	jmp    80107858 <alltraps>

80107f37 <vector9>:
.globl vector9
vector9:
  pushl $0
80107f37:	6a 00                	push   $0x0
  pushl $9
80107f39:	6a 09                	push   $0x9
  jmp alltraps
80107f3b:	e9 18 f9 ff ff       	jmp    80107858 <alltraps>

80107f40 <vector10>:
.globl vector10
vector10:
  pushl $10
80107f40:	6a 0a                	push   $0xa
  jmp alltraps
80107f42:	e9 11 f9 ff ff       	jmp    80107858 <alltraps>

80107f47 <vector11>:
.globl vector11
vector11:
  pushl $11
80107f47:	6a 0b                	push   $0xb
  jmp alltraps
80107f49:	e9 0a f9 ff ff       	jmp    80107858 <alltraps>

80107f4e <vector12>:
.globl vector12
vector12:
  pushl $12
80107f4e:	6a 0c                	push   $0xc
  jmp alltraps
80107f50:	e9 03 f9 ff ff       	jmp    80107858 <alltraps>

80107f55 <vector13>:
.globl vector13
vector13:
  pushl $13
80107f55:	6a 0d                	push   $0xd
  jmp alltraps
80107f57:	e9 fc f8 ff ff       	jmp    80107858 <alltraps>

80107f5c <vector14>:
.globl vector14
vector14:
  pushl $14
80107f5c:	6a 0e                	push   $0xe
  jmp alltraps
80107f5e:	e9 f5 f8 ff ff       	jmp    80107858 <alltraps>

80107f63 <vector15>:
.globl vector15
vector15:
  pushl $0
80107f63:	6a 00                	push   $0x0
  pushl $15
80107f65:	6a 0f                	push   $0xf
  jmp alltraps
80107f67:	e9 ec f8 ff ff       	jmp    80107858 <alltraps>

80107f6c <vector16>:
.globl vector16
vector16:
  pushl $0
80107f6c:	6a 00                	push   $0x0
  pushl $16
80107f6e:	6a 10                	push   $0x10
  jmp alltraps
80107f70:	e9 e3 f8 ff ff       	jmp    80107858 <alltraps>

80107f75 <vector17>:
.globl vector17
vector17:
  pushl $17
80107f75:	6a 11                	push   $0x11
  jmp alltraps
80107f77:	e9 dc f8 ff ff       	jmp    80107858 <alltraps>

80107f7c <vector18>:
.globl vector18
vector18:
  pushl $0
80107f7c:	6a 00                	push   $0x0
  pushl $18
80107f7e:	6a 12                	push   $0x12
  jmp alltraps
80107f80:	e9 d3 f8 ff ff       	jmp    80107858 <alltraps>

80107f85 <vector19>:
.globl vector19
vector19:
  pushl $0
80107f85:	6a 00                	push   $0x0
  pushl $19
80107f87:	6a 13                	push   $0x13
  jmp alltraps
80107f89:	e9 ca f8 ff ff       	jmp    80107858 <alltraps>

80107f8e <vector20>:
.globl vector20
vector20:
  pushl $0
80107f8e:	6a 00                	push   $0x0
  pushl $20
80107f90:	6a 14                	push   $0x14
  jmp alltraps
80107f92:	e9 c1 f8 ff ff       	jmp    80107858 <alltraps>

80107f97 <vector21>:
.globl vector21
vector21:
  pushl $0
80107f97:	6a 00                	push   $0x0
  pushl $21
80107f99:	6a 15                	push   $0x15
  jmp alltraps
80107f9b:	e9 b8 f8 ff ff       	jmp    80107858 <alltraps>

80107fa0 <vector22>:
.globl vector22
vector22:
  pushl $0
80107fa0:	6a 00                	push   $0x0
  pushl $22
80107fa2:	6a 16                	push   $0x16
  jmp alltraps
80107fa4:	e9 af f8 ff ff       	jmp    80107858 <alltraps>

80107fa9 <vector23>:
.globl vector23
vector23:
  pushl $0
80107fa9:	6a 00                	push   $0x0
  pushl $23
80107fab:	6a 17                	push   $0x17
  jmp alltraps
80107fad:	e9 a6 f8 ff ff       	jmp    80107858 <alltraps>

80107fb2 <vector24>:
.globl vector24
vector24:
  pushl $0
80107fb2:	6a 00                	push   $0x0
  pushl $24
80107fb4:	6a 18                	push   $0x18
  jmp alltraps
80107fb6:	e9 9d f8 ff ff       	jmp    80107858 <alltraps>

80107fbb <vector25>:
.globl vector25
vector25:
  pushl $0
80107fbb:	6a 00                	push   $0x0
  pushl $25
80107fbd:	6a 19                	push   $0x19
  jmp alltraps
80107fbf:	e9 94 f8 ff ff       	jmp    80107858 <alltraps>

80107fc4 <vector26>:
.globl vector26
vector26:
  pushl $0
80107fc4:	6a 00                	push   $0x0
  pushl $26
80107fc6:	6a 1a                	push   $0x1a
  jmp alltraps
80107fc8:	e9 8b f8 ff ff       	jmp    80107858 <alltraps>

80107fcd <vector27>:
.globl vector27
vector27:
  pushl $0
80107fcd:	6a 00                	push   $0x0
  pushl $27
80107fcf:	6a 1b                	push   $0x1b
  jmp alltraps
80107fd1:	e9 82 f8 ff ff       	jmp    80107858 <alltraps>

80107fd6 <vector28>:
.globl vector28
vector28:
  pushl $0
80107fd6:	6a 00                	push   $0x0
  pushl $28
80107fd8:	6a 1c                	push   $0x1c
  jmp alltraps
80107fda:	e9 79 f8 ff ff       	jmp    80107858 <alltraps>

80107fdf <vector29>:
.globl vector29
vector29:
  pushl $0
80107fdf:	6a 00                	push   $0x0
  pushl $29
80107fe1:	6a 1d                	push   $0x1d
  jmp alltraps
80107fe3:	e9 70 f8 ff ff       	jmp    80107858 <alltraps>

80107fe8 <vector30>:
.globl vector30
vector30:
  pushl $0
80107fe8:	6a 00                	push   $0x0
  pushl $30
80107fea:	6a 1e                	push   $0x1e
  jmp alltraps
80107fec:	e9 67 f8 ff ff       	jmp    80107858 <alltraps>

80107ff1 <vector31>:
.globl vector31
vector31:
  pushl $0
80107ff1:	6a 00                	push   $0x0
  pushl $31
80107ff3:	6a 1f                	push   $0x1f
  jmp alltraps
80107ff5:	e9 5e f8 ff ff       	jmp    80107858 <alltraps>

80107ffa <vector32>:
.globl vector32
vector32:
  pushl $0
80107ffa:	6a 00                	push   $0x0
  pushl $32
80107ffc:	6a 20                	push   $0x20
  jmp alltraps
80107ffe:	e9 55 f8 ff ff       	jmp    80107858 <alltraps>

80108003 <vector33>:
.globl vector33
vector33:
  pushl $0
80108003:	6a 00                	push   $0x0
  pushl $33
80108005:	6a 21                	push   $0x21
  jmp alltraps
80108007:	e9 4c f8 ff ff       	jmp    80107858 <alltraps>

8010800c <vector34>:
.globl vector34
vector34:
  pushl $0
8010800c:	6a 00                	push   $0x0
  pushl $34
8010800e:	6a 22                	push   $0x22
  jmp alltraps
80108010:	e9 43 f8 ff ff       	jmp    80107858 <alltraps>

80108015 <vector35>:
.globl vector35
vector35:
  pushl $0
80108015:	6a 00                	push   $0x0
  pushl $35
80108017:	6a 23                	push   $0x23
  jmp alltraps
80108019:	e9 3a f8 ff ff       	jmp    80107858 <alltraps>

8010801e <vector36>:
.globl vector36
vector36:
  pushl $0
8010801e:	6a 00                	push   $0x0
  pushl $36
80108020:	6a 24                	push   $0x24
  jmp alltraps
80108022:	e9 31 f8 ff ff       	jmp    80107858 <alltraps>

80108027 <vector37>:
.globl vector37
vector37:
  pushl $0
80108027:	6a 00                	push   $0x0
  pushl $37
80108029:	6a 25                	push   $0x25
  jmp alltraps
8010802b:	e9 28 f8 ff ff       	jmp    80107858 <alltraps>

80108030 <vector38>:
.globl vector38
vector38:
  pushl $0
80108030:	6a 00                	push   $0x0
  pushl $38
80108032:	6a 26                	push   $0x26
  jmp alltraps
80108034:	e9 1f f8 ff ff       	jmp    80107858 <alltraps>

80108039 <vector39>:
.globl vector39
vector39:
  pushl $0
80108039:	6a 00                	push   $0x0
  pushl $39
8010803b:	6a 27                	push   $0x27
  jmp alltraps
8010803d:	e9 16 f8 ff ff       	jmp    80107858 <alltraps>

80108042 <vector40>:
.globl vector40
vector40:
  pushl $0
80108042:	6a 00                	push   $0x0
  pushl $40
80108044:	6a 28                	push   $0x28
  jmp alltraps
80108046:	e9 0d f8 ff ff       	jmp    80107858 <alltraps>

8010804b <vector41>:
.globl vector41
vector41:
  pushl $0
8010804b:	6a 00                	push   $0x0
  pushl $41
8010804d:	6a 29                	push   $0x29
  jmp alltraps
8010804f:	e9 04 f8 ff ff       	jmp    80107858 <alltraps>

80108054 <vector42>:
.globl vector42
vector42:
  pushl $0
80108054:	6a 00                	push   $0x0
  pushl $42
80108056:	6a 2a                	push   $0x2a
  jmp alltraps
80108058:	e9 fb f7 ff ff       	jmp    80107858 <alltraps>

8010805d <vector43>:
.globl vector43
vector43:
  pushl $0
8010805d:	6a 00                	push   $0x0
  pushl $43
8010805f:	6a 2b                	push   $0x2b
  jmp alltraps
80108061:	e9 f2 f7 ff ff       	jmp    80107858 <alltraps>

80108066 <vector44>:
.globl vector44
vector44:
  pushl $0
80108066:	6a 00                	push   $0x0
  pushl $44
80108068:	6a 2c                	push   $0x2c
  jmp alltraps
8010806a:	e9 e9 f7 ff ff       	jmp    80107858 <alltraps>

8010806f <vector45>:
.globl vector45
vector45:
  pushl $0
8010806f:	6a 00                	push   $0x0
  pushl $45
80108071:	6a 2d                	push   $0x2d
  jmp alltraps
80108073:	e9 e0 f7 ff ff       	jmp    80107858 <alltraps>

80108078 <vector46>:
.globl vector46
vector46:
  pushl $0
80108078:	6a 00                	push   $0x0
  pushl $46
8010807a:	6a 2e                	push   $0x2e
  jmp alltraps
8010807c:	e9 d7 f7 ff ff       	jmp    80107858 <alltraps>

80108081 <vector47>:
.globl vector47
vector47:
  pushl $0
80108081:	6a 00                	push   $0x0
  pushl $47
80108083:	6a 2f                	push   $0x2f
  jmp alltraps
80108085:	e9 ce f7 ff ff       	jmp    80107858 <alltraps>

8010808a <vector48>:
.globl vector48
vector48:
  pushl $0
8010808a:	6a 00                	push   $0x0
  pushl $48
8010808c:	6a 30                	push   $0x30
  jmp alltraps
8010808e:	e9 c5 f7 ff ff       	jmp    80107858 <alltraps>

80108093 <vector49>:
.globl vector49
vector49:
  pushl $0
80108093:	6a 00                	push   $0x0
  pushl $49
80108095:	6a 31                	push   $0x31
  jmp alltraps
80108097:	e9 bc f7 ff ff       	jmp    80107858 <alltraps>

8010809c <vector50>:
.globl vector50
vector50:
  pushl $0
8010809c:	6a 00                	push   $0x0
  pushl $50
8010809e:	6a 32                	push   $0x32
  jmp alltraps
801080a0:	e9 b3 f7 ff ff       	jmp    80107858 <alltraps>

801080a5 <vector51>:
.globl vector51
vector51:
  pushl $0
801080a5:	6a 00                	push   $0x0
  pushl $51
801080a7:	6a 33                	push   $0x33
  jmp alltraps
801080a9:	e9 aa f7 ff ff       	jmp    80107858 <alltraps>

801080ae <vector52>:
.globl vector52
vector52:
  pushl $0
801080ae:	6a 00                	push   $0x0
  pushl $52
801080b0:	6a 34                	push   $0x34
  jmp alltraps
801080b2:	e9 a1 f7 ff ff       	jmp    80107858 <alltraps>

801080b7 <vector53>:
.globl vector53
vector53:
  pushl $0
801080b7:	6a 00                	push   $0x0
  pushl $53
801080b9:	6a 35                	push   $0x35
  jmp alltraps
801080bb:	e9 98 f7 ff ff       	jmp    80107858 <alltraps>

801080c0 <vector54>:
.globl vector54
vector54:
  pushl $0
801080c0:	6a 00                	push   $0x0
  pushl $54
801080c2:	6a 36                	push   $0x36
  jmp alltraps
801080c4:	e9 8f f7 ff ff       	jmp    80107858 <alltraps>

801080c9 <vector55>:
.globl vector55
vector55:
  pushl $0
801080c9:	6a 00                	push   $0x0
  pushl $55
801080cb:	6a 37                	push   $0x37
  jmp alltraps
801080cd:	e9 86 f7 ff ff       	jmp    80107858 <alltraps>

801080d2 <vector56>:
.globl vector56
vector56:
  pushl $0
801080d2:	6a 00                	push   $0x0
  pushl $56
801080d4:	6a 38                	push   $0x38
  jmp alltraps
801080d6:	e9 7d f7 ff ff       	jmp    80107858 <alltraps>

801080db <vector57>:
.globl vector57
vector57:
  pushl $0
801080db:	6a 00                	push   $0x0
  pushl $57
801080dd:	6a 39                	push   $0x39
  jmp alltraps
801080df:	e9 74 f7 ff ff       	jmp    80107858 <alltraps>

801080e4 <vector58>:
.globl vector58
vector58:
  pushl $0
801080e4:	6a 00                	push   $0x0
  pushl $58
801080e6:	6a 3a                	push   $0x3a
  jmp alltraps
801080e8:	e9 6b f7 ff ff       	jmp    80107858 <alltraps>

801080ed <vector59>:
.globl vector59
vector59:
  pushl $0
801080ed:	6a 00                	push   $0x0
  pushl $59
801080ef:	6a 3b                	push   $0x3b
  jmp alltraps
801080f1:	e9 62 f7 ff ff       	jmp    80107858 <alltraps>

801080f6 <vector60>:
.globl vector60
vector60:
  pushl $0
801080f6:	6a 00                	push   $0x0
  pushl $60
801080f8:	6a 3c                	push   $0x3c
  jmp alltraps
801080fa:	e9 59 f7 ff ff       	jmp    80107858 <alltraps>

801080ff <vector61>:
.globl vector61
vector61:
  pushl $0
801080ff:	6a 00                	push   $0x0
  pushl $61
80108101:	6a 3d                	push   $0x3d
  jmp alltraps
80108103:	e9 50 f7 ff ff       	jmp    80107858 <alltraps>

80108108 <vector62>:
.globl vector62
vector62:
  pushl $0
80108108:	6a 00                	push   $0x0
  pushl $62
8010810a:	6a 3e                	push   $0x3e
  jmp alltraps
8010810c:	e9 47 f7 ff ff       	jmp    80107858 <alltraps>

80108111 <vector63>:
.globl vector63
vector63:
  pushl $0
80108111:	6a 00                	push   $0x0
  pushl $63
80108113:	6a 3f                	push   $0x3f
  jmp alltraps
80108115:	e9 3e f7 ff ff       	jmp    80107858 <alltraps>

8010811a <vector64>:
.globl vector64
vector64:
  pushl $0
8010811a:	6a 00                	push   $0x0
  pushl $64
8010811c:	6a 40                	push   $0x40
  jmp alltraps
8010811e:	e9 35 f7 ff ff       	jmp    80107858 <alltraps>

80108123 <vector65>:
.globl vector65
vector65:
  pushl $0
80108123:	6a 00                	push   $0x0
  pushl $65
80108125:	6a 41                	push   $0x41
  jmp alltraps
80108127:	e9 2c f7 ff ff       	jmp    80107858 <alltraps>

8010812c <vector66>:
.globl vector66
vector66:
  pushl $0
8010812c:	6a 00                	push   $0x0
  pushl $66
8010812e:	6a 42                	push   $0x42
  jmp alltraps
80108130:	e9 23 f7 ff ff       	jmp    80107858 <alltraps>

80108135 <vector67>:
.globl vector67
vector67:
  pushl $0
80108135:	6a 00                	push   $0x0
  pushl $67
80108137:	6a 43                	push   $0x43
  jmp alltraps
80108139:	e9 1a f7 ff ff       	jmp    80107858 <alltraps>

8010813e <vector68>:
.globl vector68
vector68:
  pushl $0
8010813e:	6a 00                	push   $0x0
  pushl $68
80108140:	6a 44                	push   $0x44
  jmp alltraps
80108142:	e9 11 f7 ff ff       	jmp    80107858 <alltraps>

80108147 <vector69>:
.globl vector69
vector69:
  pushl $0
80108147:	6a 00                	push   $0x0
  pushl $69
80108149:	6a 45                	push   $0x45
  jmp alltraps
8010814b:	e9 08 f7 ff ff       	jmp    80107858 <alltraps>

80108150 <vector70>:
.globl vector70
vector70:
  pushl $0
80108150:	6a 00                	push   $0x0
  pushl $70
80108152:	6a 46                	push   $0x46
  jmp alltraps
80108154:	e9 ff f6 ff ff       	jmp    80107858 <alltraps>

80108159 <vector71>:
.globl vector71
vector71:
  pushl $0
80108159:	6a 00                	push   $0x0
  pushl $71
8010815b:	6a 47                	push   $0x47
  jmp alltraps
8010815d:	e9 f6 f6 ff ff       	jmp    80107858 <alltraps>

80108162 <vector72>:
.globl vector72
vector72:
  pushl $0
80108162:	6a 00                	push   $0x0
  pushl $72
80108164:	6a 48                	push   $0x48
  jmp alltraps
80108166:	e9 ed f6 ff ff       	jmp    80107858 <alltraps>

8010816b <vector73>:
.globl vector73
vector73:
  pushl $0
8010816b:	6a 00                	push   $0x0
  pushl $73
8010816d:	6a 49                	push   $0x49
  jmp alltraps
8010816f:	e9 e4 f6 ff ff       	jmp    80107858 <alltraps>

80108174 <vector74>:
.globl vector74
vector74:
  pushl $0
80108174:	6a 00                	push   $0x0
  pushl $74
80108176:	6a 4a                	push   $0x4a
  jmp alltraps
80108178:	e9 db f6 ff ff       	jmp    80107858 <alltraps>

8010817d <vector75>:
.globl vector75
vector75:
  pushl $0
8010817d:	6a 00                	push   $0x0
  pushl $75
8010817f:	6a 4b                	push   $0x4b
  jmp alltraps
80108181:	e9 d2 f6 ff ff       	jmp    80107858 <alltraps>

80108186 <vector76>:
.globl vector76
vector76:
  pushl $0
80108186:	6a 00                	push   $0x0
  pushl $76
80108188:	6a 4c                	push   $0x4c
  jmp alltraps
8010818a:	e9 c9 f6 ff ff       	jmp    80107858 <alltraps>

8010818f <vector77>:
.globl vector77
vector77:
  pushl $0
8010818f:	6a 00                	push   $0x0
  pushl $77
80108191:	6a 4d                	push   $0x4d
  jmp alltraps
80108193:	e9 c0 f6 ff ff       	jmp    80107858 <alltraps>

80108198 <vector78>:
.globl vector78
vector78:
  pushl $0
80108198:	6a 00                	push   $0x0
  pushl $78
8010819a:	6a 4e                	push   $0x4e
  jmp alltraps
8010819c:	e9 b7 f6 ff ff       	jmp    80107858 <alltraps>

801081a1 <vector79>:
.globl vector79
vector79:
  pushl $0
801081a1:	6a 00                	push   $0x0
  pushl $79
801081a3:	6a 4f                	push   $0x4f
  jmp alltraps
801081a5:	e9 ae f6 ff ff       	jmp    80107858 <alltraps>

801081aa <vector80>:
.globl vector80
vector80:
  pushl $0
801081aa:	6a 00                	push   $0x0
  pushl $80
801081ac:	6a 50                	push   $0x50
  jmp alltraps
801081ae:	e9 a5 f6 ff ff       	jmp    80107858 <alltraps>

801081b3 <vector81>:
.globl vector81
vector81:
  pushl $0
801081b3:	6a 00                	push   $0x0
  pushl $81
801081b5:	6a 51                	push   $0x51
  jmp alltraps
801081b7:	e9 9c f6 ff ff       	jmp    80107858 <alltraps>

801081bc <vector82>:
.globl vector82
vector82:
  pushl $0
801081bc:	6a 00                	push   $0x0
  pushl $82
801081be:	6a 52                	push   $0x52
  jmp alltraps
801081c0:	e9 93 f6 ff ff       	jmp    80107858 <alltraps>

801081c5 <vector83>:
.globl vector83
vector83:
  pushl $0
801081c5:	6a 00                	push   $0x0
  pushl $83
801081c7:	6a 53                	push   $0x53
  jmp alltraps
801081c9:	e9 8a f6 ff ff       	jmp    80107858 <alltraps>

801081ce <vector84>:
.globl vector84
vector84:
  pushl $0
801081ce:	6a 00                	push   $0x0
  pushl $84
801081d0:	6a 54                	push   $0x54
  jmp alltraps
801081d2:	e9 81 f6 ff ff       	jmp    80107858 <alltraps>

801081d7 <vector85>:
.globl vector85
vector85:
  pushl $0
801081d7:	6a 00                	push   $0x0
  pushl $85
801081d9:	6a 55                	push   $0x55
  jmp alltraps
801081db:	e9 78 f6 ff ff       	jmp    80107858 <alltraps>

801081e0 <vector86>:
.globl vector86
vector86:
  pushl $0
801081e0:	6a 00                	push   $0x0
  pushl $86
801081e2:	6a 56                	push   $0x56
  jmp alltraps
801081e4:	e9 6f f6 ff ff       	jmp    80107858 <alltraps>

801081e9 <vector87>:
.globl vector87
vector87:
  pushl $0
801081e9:	6a 00                	push   $0x0
  pushl $87
801081eb:	6a 57                	push   $0x57
  jmp alltraps
801081ed:	e9 66 f6 ff ff       	jmp    80107858 <alltraps>

801081f2 <vector88>:
.globl vector88
vector88:
  pushl $0
801081f2:	6a 00                	push   $0x0
  pushl $88
801081f4:	6a 58                	push   $0x58
  jmp alltraps
801081f6:	e9 5d f6 ff ff       	jmp    80107858 <alltraps>

801081fb <vector89>:
.globl vector89
vector89:
  pushl $0
801081fb:	6a 00                	push   $0x0
  pushl $89
801081fd:	6a 59                	push   $0x59
  jmp alltraps
801081ff:	e9 54 f6 ff ff       	jmp    80107858 <alltraps>

80108204 <vector90>:
.globl vector90
vector90:
  pushl $0
80108204:	6a 00                	push   $0x0
  pushl $90
80108206:	6a 5a                	push   $0x5a
  jmp alltraps
80108208:	e9 4b f6 ff ff       	jmp    80107858 <alltraps>

8010820d <vector91>:
.globl vector91
vector91:
  pushl $0
8010820d:	6a 00                	push   $0x0
  pushl $91
8010820f:	6a 5b                	push   $0x5b
  jmp alltraps
80108211:	e9 42 f6 ff ff       	jmp    80107858 <alltraps>

80108216 <vector92>:
.globl vector92
vector92:
  pushl $0
80108216:	6a 00                	push   $0x0
  pushl $92
80108218:	6a 5c                	push   $0x5c
  jmp alltraps
8010821a:	e9 39 f6 ff ff       	jmp    80107858 <alltraps>

8010821f <vector93>:
.globl vector93
vector93:
  pushl $0
8010821f:	6a 00                	push   $0x0
  pushl $93
80108221:	6a 5d                	push   $0x5d
  jmp alltraps
80108223:	e9 30 f6 ff ff       	jmp    80107858 <alltraps>

80108228 <vector94>:
.globl vector94
vector94:
  pushl $0
80108228:	6a 00                	push   $0x0
  pushl $94
8010822a:	6a 5e                	push   $0x5e
  jmp alltraps
8010822c:	e9 27 f6 ff ff       	jmp    80107858 <alltraps>

80108231 <vector95>:
.globl vector95
vector95:
  pushl $0
80108231:	6a 00                	push   $0x0
  pushl $95
80108233:	6a 5f                	push   $0x5f
  jmp alltraps
80108235:	e9 1e f6 ff ff       	jmp    80107858 <alltraps>

8010823a <vector96>:
.globl vector96
vector96:
  pushl $0
8010823a:	6a 00                	push   $0x0
  pushl $96
8010823c:	6a 60                	push   $0x60
  jmp alltraps
8010823e:	e9 15 f6 ff ff       	jmp    80107858 <alltraps>

80108243 <vector97>:
.globl vector97
vector97:
  pushl $0
80108243:	6a 00                	push   $0x0
  pushl $97
80108245:	6a 61                	push   $0x61
  jmp alltraps
80108247:	e9 0c f6 ff ff       	jmp    80107858 <alltraps>

8010824c <vector98>:
.globl vector98
vector98:
  pushl $0
8010824c:	6a 00                	push   $0x0
  pushl $98
8010824e:	6a 62                	push   $0x62
  jmp alltraps
80108250:	e9 03 f6 ff ff       	jmp    80107858 <alltraps>

80108255 <vector99>:
.globl vector99
vector99:
  pushl $0
80108255:	6a 00                	push   $0x0
  pushl $99
80108257:	6a 63                	push   $0x63
  jmp alltraps
80108259:	e9 fa f5 ff ff       	jmp    80107858 <alltraps>

8010825e <vector100>:
.globl vector100
vector100:
  pushl $0
8010825e:	6a 00                	push   $0x0
  pushl $100
80108260:	6a 64                	push   $0x64
  jmp alltraps
80108262:	e9 f1 f5 ff ff       	jmp    80107858 <alltraps>

80108267 <vector101>:
.globl vector101
vector101:
  pushl $0
80108267:	6a 00                	push   $0x0
  pushl $101
80108269:	6a 65                	push   $0x65
  jmp alltraps
8010826b:	e9 e8 f5 ff ff       	jmp    80107858 <alltraps>

80108270 <vector102>:
.globl vector102
vector102:
  pushl $0
80108270:	6a 00                	push   $0x0
  pushl $102
80108272:	6a 66                	push   $0x66
  jmp alltraps
80108274:	e9 df f5 ff ff       	jmp    80107858 <alltraps>

80108279 <vector103>:
.globl vector103
vector103:
  pushl $0
80108279:	6a 00                	push   $0x0
  pushl $103
8010827b:	6a 67                	push   $0x67
  jmp alltraps
8010827d:	e9 d6 f5 ff ff       	jmp    80107858 <alltraps>

80108282 <vector104>:
.globl vector104
vector104:
  pushl $0
80108282:	6a 00                	push   $0x0
  pushl $104
80108284:	6a 68                	push   $0x68
  jmp alltraps
80108286:	e9 cd f5 ff ff       	jmp    80107858 <alltraps>

8010828b <vector105>:
.globl vector105
vector105:
  pushl $0
8010828b:	6a 00                	push   $0x0
  pushl $105
8010828d:	6a 69                	push   $0x69
  jmp alltraps
8010828f:	e9 c4 f5 ff ff       	jmp    80107858 <alltraps>

80108294 <vector106>:
.globl vector106
vector106:
  pushl $0
80108294:	6a 00                	push   $0x0
  pushl $106
80108296:	6a 6a                	push   $0x6a
  jmp alltraps
80108298:	e9 bb f5 ff ff       	jmp    80107858 <alltraps>

8010829d <vector107>:
.globl vector107
vector107:
  pushl $0
8010829d:	6a 00                	push   $0x0
  pushl $107
8010829f:	6a 6b                	push   $0x6b
  jmp alltraps
801082a1:	e9 b2 f5 ff ff       	jmp    80107858 <alltraps>

801082a6 <vector108>:
.globl vector108
vector108:
  pushl $0
801082a6:	6a 00                	push   $0x0
  pushl $108
801082a8:	6a 6c                	push   $0x6c
  jmp alltraps
801082aa:	e9 a9 f5 ff ff       	jmp    80107858 <alltraps>

801082af <vector109>:
.globl vector109
vector109:
  pushl $0
801082af:	6a 00                	push   $0x0
  pushl $109
801082b1:	6a 6d                	push   $0x6d
  jmp alltraps
801082b3:	e9 a0 f5 ff ff       	jmp    80107858 <alltraps>

801082b8 <vector110>:
.globl vector110
vector110:
  pushl $0
801082b8:	6a 00                	push   $0x0
  pushl $110
801082ba:	6a 6e                	push   $0x6e
  jmp alltraps
801082bc:	e9 97 f5 ff ff       	jmp    80107858 <alltraps>

801082c1 <vector111>:
.globl vector111
vector111:
  pushl $0
801082c1:	6a 00                	push   $0x0
  pushl $111
801082c3:	6a 6f                	push   $0x6f
  jmp alltraps
801082c5:	e9 8e f5 ff ff       	jmp    80107858 <alltraps>

801082ca <vector112>:
.globl vector112
vector112:
  pushl $0
801082ca:	6a 00                	push   $0x0
  pushl $112
801082cc:	6a 70                	push   $0x70
  jmp alltraps
801082ce:	e9 85 f5 ff ff       	jmp    80107858 <alltraps>

801082d3 <vector113>:
.globl vector113
vector113:
  pushl $0
801082d3:	6a 00                	push   $0x0
  pushl $113
801082d5:	6a 71                	push   $0x71
  jmp alltraps
801082d7:	e9 7c f5 ff ff       	jmp    80107858 <alltraps>

801082dc <vector114>:
.globl vector114
vector114:
  pushl $0
801082dc:	6a 00                	push   $0x0
  pushl $114
801082de:	6a 72                	push   $0x72
  jmp alltraps
801082e0:	e9 73 f5 ff ff       	jmp    80107858 <alltraps>

801082e5 <vector115>:
.globl vector115
vector115:
  pushl $0
801082e5:	6a 00                	push   $0x0
  pushl $115
801082e7:	6a 73                	push   $0x73
  jmp alltraps
801082e9:	e9 6a f5 ff ff       	jmp    80107858 <alltraps>

801082ee <vector116>:
.globl vector116
vector116:
  pushl $0
801082ee:	6a 00                	push   $0x0
  pushl $116
801082f0:	6a 74                	push   $0x74
  jmp alltraps
801082f2:	e9 61 f5 ff ff       	jmp    80107858 <alltraps>

801082f7 <vector117>:
.globl vector117
vector117:
  pushl $0
801082f7:	6a 00                	push   $0x0
  pushl $117
801082f9:	6a 75                	push   $0x75
  jmp alltraps
801082fb:	e9 58 f5 ff ff       	jmp    80107858 <alltraps>

80108300 <vector118>:
.globl vector118
vector118:
  pushl $0
80108300:	6a 00                	push   $0x0
  pushl $118
80108302:	6a 76                	push   $0x76
  jmp alltraps
80108304:	e9 4f f5 ff ff       	jmp    80107858 <alltraps>

80108309 <vector119>:
.globl vector119
vector119:
  pushl $0
80108309:	6a 00                	push   $0x0
  pushl $119
8010830b:	6a 77                	push   $0x77
  jmp alltraps
8010830d:	e9 46 f5 ff ff       	jmp    80107858 <alltraps>

80108312 <vector120>:
.globl vector120
vector120:
  pushl $0
80108312:	6a 00                	push   $0x0
  pushl $120
80108314:	6a 78                	push   $0x78
  jmp alltraps
80108316:	e9 3d f5 ff ff       	jmp    80107858 <alltraps>

8010831b <vector121>:
.globl vector121
vector121:
  pushl $0
8010831b:	6a 00                	push   $0x0
  pushl $121
8010831d:	6a 79                	push   $0x79
  jmp alltraps
8010831f:	e9 34 f5 ff ff       	jmp    80107858 <alltraps>

80108324 <vector122>:
.globl vector122
vector122:
  pushl $0
80108324:	6a 00                	push   $0x0
  pushl $122
80108326:	6a 7a                	push   $0x7a
  jmp alltraps
80108328:	e9 2b f5 ff ff       	jmp    80107858 <alltraps>

8010832d <vector123>:
.globl vector123
vector123:
  pushl $0
8010832d:	6a 00                	push   $0x0
  pushl $123
8010832f:	6a 7b                	push   $0x7b
  jmp alltraps
80108331:	e9 22 f5 ff ff       	jmp    80107858 <alltraps>

80108336 <vector124>:
.globl vector124
vector124:
  pushl $0
80108336:	6a 00                	push   $0x0
  pushl $124
80108338:	6a 7c                	push   $0x7c
  jmp alltraps
8010833a:	e9 19 f5 ff ff       	jmp    80107858 <alltraps>

8010833f <vector125>:
.globl vector125
vector125:
  pushl $0
8010833f:	6a 00                	push   $0x0
  pushl $125
80108341:	6a 7d                	push   $0x7d
  jmp alltraps
80108343:	e9 10 f5 ff ff       	jmp    80107858 <alltraps>

80108348 <vector126>:
.globl vector126
vector126:
  pushl $0
80108348:	6a 00                	push   $0x0
  pushl $126
8010834a:	6a 7e                	push   $0x7e
  jmp alltraps
8010834c:	e9 07 f5 ff ff       	jmp    80107858 <alltraps>

80108351 <vector127>:
.globl vector127
vector127:
  pushl $0
80108351:	6a 00                	push   $0x0
  pushl $127
80108353:	6a 7f                	push   $0x7f
  jmp alltraps
80108355:	e9 fe f4 ff ff       	jmp    80107858 <alltraps>

8010835a <vector128>:
.globl vector128
vector128:
  pushl $0
8010835a:	6a 00                	push   $0x0
  pushl $128
8010835c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80108361:	e9 f2 f4 ff ff       	jmp    80107858 <alltraps>

80108366 <vector129>:
.globl vector129
vector129:
  pushl $0
80108366:	6a 00                	push   $0x0
  pushl $129
80108368:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010836d:	e9 e6 f4 ff ff       	jmp    80107858 <alltraps>

80108372 <vector130>:
.globl vector130
vector130:
  pushl $0
80108372:	6a 00                	push   $0x0
  pushl $130
80108374:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108379:	e9 da f4 ff ff       	jmp    80107858 <alltraps>

8010837e <vector131>:
.globl vector131
vector131:
  pushl $0
8010837e:	6a 00                	push   $0x0
  pushl $131
80108380:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80108385:	e9 ce f4 ff ff       	jmp    80107858 <alltraps>

8010838a <vector132>:
.globl vector132
vector132:
  pushl $0
8010838a:	6a 00                	push   $0x0
  pushl $132
8010838c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80108391:	e9 c2 f4 ff ff       	jmp    80107858 <alltraps>

80108396 <vector133>:
.globl vector133
vector133:
  pushl $0
80108396:	6a 00                	push   $0x0
  pushl $133
80108398:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010839d:	e9 b6 f4 ff ff       	jmp    80107858 <alltraps>

801083a2 <vector134>:
.globl vector134
vector134:
  pushl $0
801083a2:	6a 00                	push   $0x0
  pushl $134
801083a4:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801083a9:	e9 aa f4 ff ff       	jmp    80107858 <alltraps>

801083ae <vector135>:
.globl vector135
vector135:
  pushl $0
801083ae:	6a 00                	push   $0x0
  pushl $135
801083b0:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801083b5:	e9 9e f4 ff ff       	jmp    80107858 <alltraps>

801083ba <vector136>:
.globl vector136
vector136:
  pushl $0
801083ba:	6a 00                	push   $0x0
  pushl $136
801083bc:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801083c1:	e9 92 f4 ff ff       	jmp    80107858 <alltraps>

801083c6 <vector137>:
.globl vector137
vector137:
  pushl $0
801083c6:	6a 00                	push   $0x0
  pushl $137
801083c8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801083cd:	e9 86 f4 ff ff       	jmp    80107858 <alltraps>

801083d2 <vector138>:
.globl vector138
vector138:
  pushl $0
801083d2:	6a 00                	push   $0x0
  pushl $138
801083d4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801083d9:	e9 7a f4 ff ff       	jmp    80107858 <alltraps>

801083de <vector139>:
.globl vector139
vector139:
  pushl $0
801083de:	6a 00                	push   $0x0
  pushl $139
801083e0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801083e5:	e9 6e f4 ff ff       	jmp    80107858 <alltraps>

801083ea <vector140>:
.globl vector140
vector140:
  pushl $0
801083ea:	6a 00                	push   $0x0
  pushl $140
801083ec:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801083f1:	e9 62 f4 ff ff       	jmp    80107858 <alltraps>

801083f6 <vector141>:
.globl vector141
vector141:
  pushl $0
801083f6:	6a 00                	push   $0x0
  pushl $141
801083f8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801083fd:	e9 56 f4 ff ff       	jmp    80107858 <alltraps>

80108402 <vector142>:
.globl vector142
vector142:
  pushl $0
80108402:	6a 00                	push   $0x0
  pushl $142
80108404:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108409:	e9 4a f4 ff ff       	jmp    80107858 <alltraps>

8010840e <vector143>:
.globl vector143
vector143:
  pushl $0
8010840e:	6a 00                	push   $0x0
  pushl $143
80108410:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80108415:	e9 3e f4 ff ff       	jmp    80107858 <alltraps>

8010841a <vector144>:
.globl vector144
vector144:
  pushl $0
8010841a:	6a 00                	push   $0x0
  pushl $144
8010841c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80108421:	e9 32 f4 ff ff       	jmp    80107858 <alltraps>

80108426 <vector145>:
.globl vector145
vector145:
  pushl $0
80108426:	6a 00                	push   $0x0
  pushl $145
80108428:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010842d:	e9 26 f4 ff ff       	jmp    80107858 <alltraps>

80108432 <vector146>:
.globl vector146
vector146:
  pushl $0
80108432:	6a 00                	push   $0x0
  pushl $146
80108434:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108439:	e9 1a f4 ff ff       	jmp    80107858 <alltraps>

8010843e <vector147>:
.globl vector147
vector147:
  pushl $0
8010843e:	6a 00                	push   $0x0
  pushl $147
80108440:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80108445:	e9 0e f4 ff ff       	jmp    80107858 <alltraps>

8010844a <vector148>:
.globl vector148
vector148:
  pushl $0
8010844a:	6a 00                	push   $0x0
  pushl $148
8010844c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80108451:	e9 02 f4 ff ff       	jmp    80107858 <alltraps>

80108456 <vector149>:
.globl vector149
vector149:
  pushl $0
80108456:	6a 00                	push   $0x0
  pushl $149
80108458:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010845d:	e9 f6 f3 ff ff       	jmp    80107858 <alltraps>

80108462 <vector150>:
.globl vector150
vector150:
  pushl $0
80108462:	6a 00                	push   $0x0
  pushl $150
80108464:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108469:	e9 ea f3 ff ff       	jmp    80107858 <alltraps>

8010846e <vector151>:
.globl vector151
vector151:
  pushl $0
8010846e:	6a 00                	push   $0x0
  pushl $151
80108470:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80108475:	e9 de f3 ff ff       	jmp    80107858 <alltraps>

8010847a <vector152>:
.globl vector152
vector152:
  pushl $0
8010847a:	6a 00                	push   $0x0
  pushl $152
8010847c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80108481:	e9 d2 f3 ff ff       	jmp    80107858 <alltraps>

80108486 <vector153>:
.globl vector153
vector153:
  pushl $0
80108486:	6a 00                	push   $0x0
  pushl $153
80108488:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010848d:	e9 c6 f3 ff ff       	jmp    80107858 <alltraps>

80108492 <vector154>:
.globl vector154
vector154:
  pushl $0
80108492:	6a 00                	push   $0x0
  pushl $154
80108494:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108499:	e9 ba f3 ff ff       	jmp    80107858 <alltraps>

8010849e <vector155>:
.globl vector155
vector155:
  pushl $0
8010849e:	6a 00                	push   $0x0
  pushl $155
801084a0:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801084a5:	e9 ae f3 ff ff       	jmp    80107858 <alltraps>

801084aa <vector156>:
.globl vector156
vector156:
  pushl $0
801084aa:	6a 00                	push   $0x0
  pushl $156
801084ac:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801084b1:	e9 a2 f3 ff ff       	jmp    80107858 <alltraps>

801084b6 <vector157>:
.globl vector157
vector157:
  pushl $0
801084b6:	6a 00                	push   $0x0
  pushl $157
801084b8:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801084bd:	e9 96 f3 ff ff       	jmp    80107858 <alltraps>

801084c2 <vector158>:
.globl vector158
vector158:
  pushl $0
801084c2:	6a 00                	push   $0x0
  pushl $158
801084c4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801084c9:	e9 8a f3 ff ff       	jmp    80107858 <alltraps>

801084ce <vector159>:
.globl vector159
vector159:
  pushl $0
801084ce:	6a 00                	push   $0x0
  pushl $159
801084d0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801084d5:	e9 7e f3 ff ff       	jmp    80107858 <alltraps>

801084da <vector160>:
.globl vector160
vector160:
  pushl $0
801084da:	6a 00                	push   $0x0
  pushl $160
801084dc:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801084e1:	e9 72 f3 ff ff       	jmp    80107858 <alltraps>

801084e6 <vector161>:
.globl vector161
vector161:
  pushl $0
801084e6:	6a 00                	push   $0x0
  pushl $161
801084e8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801084ed:	e9 66 f3 ff ff       	jmp    80107858 <alltraps>

801084f2 <vector162>:
.globl vector162
vector162:
  pushl $0
801084f2:	6a 00                	push   $0x0
  pushl $162
801084f4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801084f9:	e9 5a f3 ff ff       	jmp    80107858 <alltraps>

801084fe <vector163>:
.globl vector163
vector163:
  pushl $0
801084fe:	6a 00                	push   $0x0
  pushl $163
80108500:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108505:	e9 4e f3 ff ff       	jmp    80107858 <alltraps>

8010850a <vector164>:
.globl vector164
vector164:
  pushl $0
8010850a:	6a 00                	push   $0x0
  pushl $164
8010850c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108511:	e9 42 f3 ff ff       	jmp    80107858 <alltraps>

80108516 <vector165>:
.globl vector165
vector165:
  pushl $0
80108516:	6a 00                	push   $0x0
  pushl $165
80108518:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010851d:	e9 36 f3 ff ff       	jmp    80107858 <alltraps>

80108522 <vector166>:
.globl vector166
vector166:
  pushl $0
80108522:	6a 00                	push   $0x0
  pushl $166
80108524:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108529:	e9 2a f3 ff ff       	jmp    80107858 <alltraps>

8010852e <vector167>:
.globl vector167
vector167:
  pushl $0
8010852e:	6a 00                	push   $0x0
  pushl $167
80108530:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108535:	e9 1e f3 ff ff       	jmp    80107858 <alltraps>

8010853a <vector168>:
.globl vector168
vector168:
  pushl $0
8010853a:	6a 00                	push   $0x0
  pushl $168
8010853c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80108541:	e9 12 f3 ff ff       	jmp    80107858 <alltraps>

80108546 <vector169>:
.globl vector169
vector169:
  pushl $0
80108546:	6a 00                	push   $0x0
  pushl $169
80108548:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010854d:	e9 06 f3 ff ff       	jmp    80107858 <alltraps>

80108552 <vector170>:
.globl vector170
vector170:
  pushl $0
80108552:	6a 00                	push   $0x0
  pushl $170
80108554:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108559:	e9 fa f2 ff ff       	jmp    80107858 <alltraps>

8010855e <vector171>:
.globl vector171
vector171:
  pushl $0
8010855e:	6a 00                	push   $0x0
  pushl $171
80108560:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80108565:	e9 ee f2 ff ff       	jmp    80107858 <alltraps>

8010856a <vector172>:
.globl vector172
vector172:
  pushl $0
8010856a:	6a 00                	push   $0x0
  pushl $172
8010856c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80108571:	e9 e2 f2 ff ff       	jmp    80107858 <alltraps>

80108576 <vector173>:
.globl vector173
vector173:
  pushl $0
80108576:	6a 00                	push   $0x0
  pushl $173
80108578:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010857d:	e9 d6 f2 ff ff       	jmp    80107858 <alltraps>

80108582 <vector174>:
.globl vector174
vector174:
  pushl $0
80108582:	6a 00                	push   $0x0
  pushl $174
80108584:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108589:	e9 ca f2 ff ff       	jmp    80107858 <alltraps>

8010858e <vector175>:
.globl vector175
vector175:
  pushl $0
8010858e:	6a 00                	push   $0x0
  pushl $175
80108590:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108595:	e9 be f2 ff ff       	jmp    80107858 <alltraps>

8010859a <vector176>:
.globl vector176
vector176:
  pushl $0
8010859a:	6a 00                	push   $0x0
  pushl $176
8010859c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801085a1:	e9 b2 f2 ff ff       	jmp    80107858 <alltraps>

801085a6 <vector177>:
.globl vector177
vector177:
  pushl $0
801085a6:	6a 00                	push   $0x0
  pushl $177
801085a8:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801085ad:	e9 a6 f2 ff ff       	jmp    80107858 <alltraps>

801085b2 <vector178>:
.globl vector178
vector178:
  pushl $0
801085b2:	6a 00                	push   $0x0
  pushl $178
801085b4:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801085b9:	e9 9a f2 ff ff       	jmp    80107858 <alltraps>

801085be <vector179>:
.globl vector179
vector179:
  pushl $0
801085be:	6a 00                	push   $0x0
  pushl $179
801085c0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801085c5:	e9 8e f2 ff ff       	jmp    80107858 <alltraps>

801085ca <vector180>:
.globl vector180
vector180:
  pushl $0
801085ca:	6a 00                	push   $0x0
  pushl $180
801085cc:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801085d1:	e9 82 f2 ff ff       	jmp    80107858 <alltraps>

801085d6 <vector181>:
.globl vector181
vector181:
  pushl $0
801085d6:	6a 00                	push   $0x0
  pushl $181
801085d8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801085dd:	e9 76 f2 ff ff       	jmp    80107858 <alltraps>

801085e2 <vector182>:
.globl vector182
vector182:
  pushl $0
801085e2:	6a 00                	push   $0x0
  pushl $182
801085e4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801085e9:	e9 6a f2 ff ff       	jmp    80107858 <alltraps>

801085ee <vector183>:
.globl vector183
vector183:
  pushl $0
801085ee:	6a 00                	push   $0x0
  pushl $183
801085f0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801085f5:	e9 5e f2 ff ff       	jmp    80107858 <alltraps>

801085fa <vector184>:
.globl vector184
vector184:
  pushl $0
801085fa:	6a 00                	push   $0x0
  pushl $184
801085fc:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108601:	e9 52 f2 ff ff       	jmp    80107858 <alltraps>

80108606 <vector185>:
.globl vector185
vector185:
  pushl $0
80108606:	6a 00                	push   $0x0
  pushl $185
80108608:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010860d:	e9 46 f2 ff ff       	jmp    80107858 <alltraps>

80108612 <vector186>:
.globl vector186
vector186:
  pushl $0
80108612:	6a 00                	push   $0x0
  pushl $186
80108614:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108619:	e9 3a f2 ff ff       	jmp    80107858 <alltraps>

8010861e <vector187>:
.globl vector187
vector187:
  pushl $0
8010861e:	6a 00                	push   $0x0
  pushl $187
80108620:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108625:	e9 2e f2 ff ff       	jmp    80107858 <alltraps>

8010862a <vector188>:
.globl vector188
vector188:
  pushl $0
8010862a:	6a 00                	push   $0x0
  pushl $188
8010862c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108631:	e9 22 f2 ff ff       	jmp    80107858 <alltraps>

80108636 <vector189>:
.globl vector189
vector189:
  pushl $0
80108636:	6a 00                	push   $0x0
  pushl $189
80108638:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010863d:	e9 16 f2 ff ff       	jmp    80107858 <alltraps>

80108642 <vector190>:
.globl vector190
vector190:
  pushl $0
80108642:	6a 00                	push   $0x0
  pushl $190
80108644:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108649:	e9 0a f2 ff ff       	jmp    80107858 <alltraps>

8010864e <vector191>:
.globl vector191
vector191:
  pushl $0
8010864e:	6a 00                	push   $0x0
  pushl $191
80108650:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80108655:	e9 fe f1 ff ff       	jmp    80107858 <alltraps>

8010865a <vector192>:
.globl vector192
vector192:
  pushl $0
8010865a:	6a 00                	push   $0x0
  pushl $192
8010865c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80108661:	e9 f2 f1 ff ff       	jmp    80107858 <alltraps>

80108666 <vector193>:
.globl vector193
vector193:
  pushl $0
80108666:	6a 00                	push   $0x0
  pushl $193
80108668:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010866d:	e9 e6 f1 ff ff       	jmp    80107858 <alltraps>

80108672 <vector194>:
.globl vector194
vector194:
  pushl $0
80108672:	6a 00                	push   $0x0
  pushl $194
80108674:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108679:	e9 da f1 ff ff       	jmp    80107858 <alltraps>

8010867e <vector195>:
.globl vector195
vector195:
  pushl $0
8010867e:	6a 00                	push   $0x0
  pushl $195
80108680:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108685:	e9 ce f1 ff ff       	jmp    80107858 <alltraps>

8010868a <vector196>:
.globl vector196
vector196:
  pushl $0
8010868a:	6a 00                	push   $0x0
  pushl $196
8010868c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108691:	e9 c2 f1 ff ff       	jmp    80107858 <alltraps>

80108696 <vector197>:
.globl vector197
vector197:
  pushl $0
80108696:	6a 00                	push   $0x0
  pushl $197
80108698:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010869d:	e9 b6 f1 ff ff       	jmp    80107858 <alltraps>

801086a2 <vector198>:
.globl vector198
vector198:
  pushl $0
801086a2:	6a 00                	push   $0x0
  pushl $198
801086a4:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801086a9:	e9 aa f1 ff ff       	jmp    80107858 <alltraps>

801086ae <vector199>:
.globl vector199
vector199:
  pushl $0
801086ae:	6a 00                	push   $0x0
  pushl $199
801086b0:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801086b5:	e9 9e f1 ff ff       	jmp    80107858 <alltraps>

801086ba <vector200>:
.globl vector200
vector200:
  pushl $0
801086ba:	6a 00                	push   $0x0
  pushl $200
801086bc:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801086c1:	e9 92 f1 ff ff       	jmp    80107858 <alltraps>

801086c6 <vector201>:
.globl vector201
vector201:
  pushl $0
801086c6:	6a 00                	push   $0x0
  pushl $201
801086c8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801086cd:	e9 86 f1 ff ff       	jmp    80107858 <alltraps>

801086d2 <vector202>:
.globl vector202
vector202:
  pushl $0
801086d2:	6a 00                	push   $0x0
  pushl $202
801086d4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801086d9:	e9 7a f1 ff ff       	jmp    80107858 <alltraps>

801086de <vector203>:
.globl vector203
vector203:
  pushl $0
801086de:	6a 00                	push   $0x0
  pushl $203
801086e0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801086e5:	e9 6e f1 ff ff       	jmp    80107858 <alltraps>

801086ea <vector204>:
.globl vector204
vector204:
  pushl $0
801086ea:	6a 00                	push   $0x0
  pushl $204
801086ec:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801086f1:	e9 62 f1 ff ff       	jmp    80107858 <alltraps>

801086f6 <vector205>:
.globl vector205
vector205:
  pushl $0
801086f6:	6a 00                	push   $0x0
  pushl $205
801086f8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801086fd:	e9 56 f1 ff ff       	jmp    80107858 <alltraps>

80108702 <vector206>:
.globl vector206
vector206:
  pushl $0
80108702:	6a 00                	push   $0x0
  pushl $206
80108704:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108709:	e9 4a f1 ff ff       	jmp    80107858 <alltraps>

8010870e <vector207>:
.globl vector207
vector207:
  pushl $0
8010870e:	6a 00                	push   $0x0
  pushl $207
80108710:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108715:	e9 3e f1 ff ff       	jmp    80107858 <alltraps>

8010871a <vector208>:
.globl vector208
vector208:
  pushl $0
8010871a:	6a 00                	push   $0x0
  pushl $208
8010871c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108721:	e9 32 f1 ff ff       	jmp    80107858 <alltraps>

80108726 <vector209>:
.globl vector209
vector209:
  pushl $0
80108726:	6a 00                	push   $0x0
  pushl $209
80108728:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010872d:	e9 26 f1 ff ff       	jmp    80107858 <alltraps>

80108732 <vector210>:
.globl vector210
vector210:
  pushl $0
80108732:	6a 00                	push   $0x0
  pushl $210
80108734:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108739:	e9 1a f1 ff ff       	jmp    80107858 <alltraps>

8010873e <vector211>:
.globl vector211
vector211:
  pushl $0
8010873e:	6a 00                	push   $0x0
  pushl $211
80108740:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108745:	e9 0e f1 ff ff       	jmp    80107858 <alltraps>

8010874a <vector212>:
.globl vector212
vector212:
  pushl $0
8010874a:	6a 00                	push   $0x0
  pushl $212
8010874c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80108751:	e9 02 f1 ff ff       	jmp    80107858 <alltraps>

80108756 <vector213>:
.globl vector213
vector213:
  pushl $0
80108756:	6a 00                	push   $0x0
  pushl $213
80108758:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010875d:	e9 f6 f0 ff ff       	jmp    80107858 <alltraps>

80108762 <vector214>:
.globl vector214
vector214:
  pushl $0
80108762:	6a 00                	push   $0x0
  pushl $214
80108764:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108769:	e9 ea f0 ff ff       	jmp    80107858 <alltraps>

8010876e <vector215>:
.globl vector215
vector215:
  pushl $0
8010876e:	6a 00                	push   $0x0
  pushl $215
80108770:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108775:	e9 de f0 ff ff       	jmp    80107858 <alltraps>

8010877a <vector216>:
.globl vector216
vector216:
  pushl $0
8010877a:	6a 00                	push   $0x0
  pushl $216
8010877c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108781:	e9 d2 f0 ff ff       	jmp    80107858 <alltraps>

80108786 <vector217>:
.globl vector217
vector217:
  pushl $0
80108786:	6a 00                	push   $0x0
  pushl $217
80108788:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010878d:	e9 c6 f0 ff ff       	jmp    80107858 <alltraps>

80108792 <vector218>:
.globl vector218
vector218:
  pushl $0
80108792:	6a 00                	push   $0x0
  pushl $218
80108794:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108799:	e9 ba f0 ff ff       	jmp    80107858 <alltraps>

8010879e <vector219>:
.globl vector219
vector219:
  pushl $0
8010879e:	6a 00                	push   $0x0
  pushl $219
801087a0:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801087a5:	e9 ae f0 ff ff       	jmp    80107858 <alltraps>

801087aa <vector220>:
.globl vector220
vector220:
  pushl $0
801087aa:	6a 00                	push   $0x0
  pushl $220
801087ac:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801087b1:	e9 a2 f0 ff ff       	jmp    80107858 <alltraps>

801087b6 <vector221>:
.globl vector221
vector221:
  pushl $0
801087b6:	6a 00                	push   $0x0
  pushl $221
801087b8:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801087bd:	e9 96 f0 ff ff       	jmp    80107858 <alltraps>

801087c2 <vector222>:
.globl vector222
vector222:
  pushl $0
801087c2:	6a 00                	push   $0x0
  pushl $222
801087c4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801087c9:	e9 8a f0 ff ff       	jmp    80107858 <alltraps>

801087ce <vector223>:
.globl vector223
vector223:
  pushl $0
801087ce:	6a 00                	push   $0x0
  pushl $223
801087d0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801087d5:	e9 7e f0 ff ff       	jmp    80107858 <alltraps>

801087da <vector224>:
.globl vector224
vector224:
  pushl $0
801087da:	6a 00                	push   $0x0
  pushl $224
801087dc:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801087e1:	e9 72 f0 ff ff       	jmp    80107858 <alltraps>

801087e6 <vector225>:
.globl vector225
vector225:
  pushl $0
801087e6:	6a 00                	push   $0x0
  pushl $225
801087e8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801087ed:	e9 66 f0 ff ff       	jmp    80107858 <alltraps>

801087f2 <vector226>:
.globl vector226
vector226:
  pushl $0
801087f2:	6a 00                	push   $0x0
  pushl $226
801087f4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801087f9:	e9 5a f0 ff ff       	jmp    80107858 <alltraps>

801087fe <vector227>:
.globl vector227
vector227:
  pushl $0
801087fe:	6a 00                	push   $0x0
  pushl $227
80108800:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108805:	e9 4e f0 ff ff       	jmp    80107858 <alltraps>

8010880a <vector228>:
.globl vector228
vector228:
  pushl $0
8010880a:	6a 00                	push   $0x0
  pushl $228
8010880c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108811:	e9 42 f0 ff ff       	jmp    80107858 <alltraps>

80108816 <vector229>:
.globl vector229
vector229:
  pushl $0
80108816:	6a 00                	push   $0x0
  pushl $229
80108818:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010881d:	e9 36 f0 ff ff       	jmp    80107858 <alltraps>

80108822 <vector230>:
.globl vector230
vector230:
  pushl $0
80108822:	6a 00                	push   $0x0
  pushl $230
80108824:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108829:	e9 2a f0 ff ff       	jmp    80107858 <alltraps>

8010882e <vector231>:
.globl vector231
vector231:
  pushl $0
8010882e:	6a 00                	push   $0x0
  pushl $231
80108830:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108835:	e9 1e f0 ff ff       	jmp    80107858 <alltraps>

8010883a <vector232>:
.globl vector232
vector232:
  pushl $0
8010883a:	6a 00                	push   $0x0
  pushl $232
8010883c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108841:	e9 12 f0 ff ff       	jmp    80107858 <alltraps>

80108846 <vector233>:
.globl vector233
vector233:
  pushl $0
80108846:	6a 00                	push   $0x0
  pushl $233
80108848:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010884d:	e9 06 f0 ff ff       	jmp    80107858 <alltraps>

80108852 <vector234>:
.globl vector234
vector234:
  pushl $0
80108852:	6a 00                	push   $0x0
  pushl $234
80108854:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108859:	e9 fa ef ff ff       	jmp    80107858 <alltraps>

8010885e <vector235>:
.globl vector235
vector235:
  pushl $0
8010885e:	6a 00                	push   $0x0
  pushl $235
80108860:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80108865:	e9 ee ef ff ff       	jmp    80107858 <alltraps>

8010886a <vector236>:
.globl vector236
vector236:
  pushl $0
8010886a:	6a 00                	push   $0x0
  pushl $236
8010886c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108871:	e9 e2 ef ff ff       	jmp    80107858 <alltraps>

80108876 <vector237>:
.globl vector237
vector237:
  pushl $0
80108876:	6a 00                	push   $0x0
  pushl $237
80108878:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010887d:	e9 d6 ef ff ff       	jmp    80107858 <alltraps>

80108882 <vector238>:
.globl vector238
vector238:
  pushl $0
80108882:	6a 00                	push   $0x0
  pushl $238
80108884:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108889:	e9 ca ef ff ff       	jmp    80107858 <alltraps>

8010888e <vector239>:
.globl vector239
vector239:
  pushl $0
8010888e:	6a 00                	push   $0x0
  pushl $239
80108890:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108895:	e9 be ef ff ff       	jmp    80107858 <alltraps>

8010889a <vector240>:
.globl vector240
vector240:
  pushl $0
8010889a:	6a 00                	push   $0x0
  pushl $240
8010889c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801088a1:	e9 b2 ef ff ff       	jmp    80107858 <alltraps>

801088a6 <vector241>:
.globl vector241
vector241:
  pushl $0
801088a6:	6a 00                	push   $0x0
  pushl $241
801088a8:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801088ad:	e9 a6 ef ff ff       	jmp    80107858 <alltraps>

801088b2 <vector242>:
.globl vector242
vector242:
  pushl $0
801088b2:	6a 00                	push   $0x0
  pushl $242
801088b4:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801088b9:	e9 9a ef ff ff       	jmp    80107858 <alltraps>

801088be <vector243>:
.globl vector243
vector243:
  pushl $0
801088be:	6a 00                	push   $0x0
  pushl $243
801088c0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801088c5:	e9 8e ef ff ff       	jmp    80107858 <alltraps>

801088ca <vector244>:
.globl vector244
vector244:
  pushl $0
801088ca:	6a 00                	push   $0x0
  pushl $244
801088cc:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801088d1:	e9 82 ef ff ff       	jmp    80107858 <alltraps>

801088d6 <vector245>:
.globl vector245
vector245:
  pushl $0
801088d6:	6a 00                	push   $0x0
  pushl $245
801088d8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801088dd:	e9 76 ef ff ff       	jmp    80107858 <alltraps>

801088e2 <vector246>:
.globl vector246
vector246:
  pushl $0
801088e2:	6a 00                	push   $0x0
  pushl $246
801088e4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801088e9:	e9 6a ef ff ff       	jmp    80107858 <alltraps>

801088ee <vector247>:
.globl vector247
vector247:
  pushl $0
801088ee:	6a 00                	push   $0x0
  pushl $247
801088f0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801088f5:	e9 5e ef ff ff       	jmp    80107858 <alltraps>

801088fa <vector248>:
.globl vector248
vector248:
  pushl $0
801088fa:	6a 00                	push   $0x0
  pushl $248
801088fc:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108901:	e9 52 ef ff ff       	jmp    80107858 <alltraps>

80108906 <vector249>:
.globl vector249
vector249:
  pushl $0
80108906:	6a 00                	push   $0x0
  pushl $249
80108908:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010890d:	e9 46 ef ff ff       	jmp    80107858 <alltraps>

80108912 <vector250>:
.globl vector250
vector250:
  pushl $0
80108912:	6a 00                	push   $0x0
  pushl $250
80108914:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108919:	e9 3a ef ff ff       	jmp    80107858 <alltraps>

8010891e <vector251>:
.globl vector251
vector251:
  pushl $0
8010891e:	6a 00                	push   $0x0
  pushl $251
80108920:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108925:	e9 2e ef ff ff       	jmp    80107858 <alltraps>

8010892a <vector252>:
.globl vector252
vector252:
  pushl $0
8010892a:	6a 00                	push   $0x0
  pushl $252
8010892c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108931:	e9 22 ef ff ff       	jmp    80107858 <alltraps>

80108936 <vector253>:
.globl vector253
vector253:
  pushl $0
80108936:	6a 00                	push   $0x0
  pushl $253
80108938:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010893d:	e9 16 ef ff ff       	jmp    80107858 <alltraps>

80108942 <vector254>:
.globl vector254
vector254:
  pushl $0
80108942:	6a 00                	push   $0x0
  pushl $254
80108944:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108949:	e9 0a ef ff ff       	jmp    80107858 <alltraps>

8010894e <vector255>:
.globl vector255
vector255:
  pushl $0
8010894e:	6a 00                	push   $0x0
  pushl $255
80108950:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108955:	e9 fe ee ff ff       	jmp    80107858 <alltraps>
	...

8010895c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010895c:	55                   	push   %ebp
8010895d:	89 e5                	mov    %esp,%ebp
8010895f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108962:	8b 45 0c             	mov    0xc(%ebp),%eax
80108965:	83 e8 01             	sub    $0x1,%eax
80108968:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010896c:	8b 45 08             	mov    0x8(%ebp),%eax
8010896f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108973:	8b 45 08             	mov    0x8(%ebp),%eax
80108976:	c1 e8 10             	shr    $0x10,%eax
80108979:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010897d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108980:	0f 01 10             	lgdtl  (%eax)
}
80108983:	c9                   	leave  
80108984:	c3                   	ret    

80108985 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108985:	55                   	push   %ebp
80108986:	89 e5                	mov    %esp,%ebp
80108988:	83 ec 04             	sub    $0x4,%esp
8010898b:	8b 45 08             	mov    0x8(%ebp),%eax
8010898e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108992:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108996:	0f 00 d8             	ltr    %ax
}
80108999:	c9                   	leave  
8010899a:	c3                   	ret    

8010899b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010899b:	55                   	push   %ebp
8010899c:	89 e5                	mov    %esp,%ebp
8010899e:	83 ec 04             	sub    $0x4,%esp
801089a1:	8b 45 08             	mov    0x8(%ebp),%eax
801089a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801089a8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801089ac:	8e e8                	mov    %eax,%gs
}
801089ae:	c9                   	leave  
801089af:	c3                   	ret    

801089b0 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801089b0:	55                   	push   %ebp
801089b1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801089b3:	8b 45 08             	mov    0x8(%ebp),%eax
801089b6:	0f 22 d8             	mov    %eax,%cr3
}
801089b9:	5d                   	pop    %ebp
801089ba:	c3                   	ret    

801089bb <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801089bb:	55                   	push   %ebp
801089bc:	89 e5                	mov    %esp,%ebp
801089be:	8b 45 08             	mov    0x8(%ebp),%eax
801089c1:	05 00 00 00 80       	add    $0x80000000,%eax
801089c6:	5d                   	pop    %ebp
801089c7:	c3                   	ret    

801089c8 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801089c8:	55                   	push   %ebp
801089c9:	89 e5                	mov    %esp,%ebp
801089cb:	8b 45 08             	mov    0x8(%ebp),%eax
801089ce:	05 00 00 00 80       	add    $0x80000000,%eax
801089d3:	5d                   	pop    %ebp
801089d4:	c3                   	ret    

801089d5 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801089d5:	55                   	push   %ebp
801089d6:	89 e5                	mov    %esp,%ebp
801089d8:	53                   	push   %ebx
801089d9:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801089dc:	e8 a0 a4 ff ff       	call   80102e81 <cpunum>
801089e1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801089e7:	05 80 19 11 80       	add    $0x80111980,%eax
801089ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801089ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801089f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a04:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108a0f:	83 e2 f0             	and    $0xfffffff0,%edx
80108a12:	83 ca 0a             	or     $0xa,%edx
80108a15:	88 50 7d             	mov    %dl,0x7d(%eax)
80108a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108a1f:	83 ca 10             	or     $0x10,%edx
80108a22:	88 50 7d             	mov    %dl,0x7d(%eax)
80108a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a28:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108a2c:	83 e2 9f             	and    $0xffffff9f,%edx
80108a2f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a35:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108a39:	83 ca 80             	or     $0xffffff80,%edx
80108a3c:	88 50 7d             	mov    %dl,0x7d(%eax)
80108a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a42:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108a46:	83 ca 0f             	or     $0xf,%edx
80108a49:	88 50 7e             	mov    %dl,0x7e(%eax)
80108a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108a53:	83 e2 ef             	and    $0xffffffef,%edx
80108a56:	88 50 7e             	mov    %dl,0x7e(%eax)
80108a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108a60:	83 e2 df             	and    $0xffffffdf,%edx
80108a63:	88 50 7e             	mov    %dl,0x7e(%eax)
80108a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a69:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108a6d:	83 ca 40             	or     $0x40,%edx
80108a70:	88 50 7e             	mov    %dl,0x7e(%eax)
80108a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a76:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108a7a:	83 ca 80             	or     $0xffffff80,%edx
80108a7d:	88 50 7e             	mov    %dl,0x7e(%eax)
80108a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a83:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108a91:	ff ff 
80108a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a96:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108a9d:	00 00 
80108a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aac:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108ab3:	83 e2 f0             	and    $0xfffffff0,%edx
80108ab6:	83 ca 02             	or     $0x2,%edx
80108ab9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108ac9:	83 ca 10             	or     $0x10,%edx
80108acc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108adc:	83 e2 9f             	and    $0xffffff9f,%edx
80108adf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108aef:	83 ca 80             	or     $0xffffff80,%edx
80108af2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108afb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108b02:	83 ca 0f             	or     $0xf,%edx
80108b05:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108b15:	83 e2 ef             	and    $0xffffffef,%edx
80108b18:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b21:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108b28:	83 e2 df             	and    $0xffffffdf,%edx
80108b2b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b34:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108b3b:	83 ca 40             	or     $0x40,%edx
80108b3e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b47:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108b4e:	83 ca 80             	or     $0xffffff80,%edx
80108b51:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b5a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b64:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108b6b:	ff ff 
80108b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b70:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108b77:	00 00 
80108b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b86:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108b8d:	83 e2 f0             	and    $0xfffffff0,%edx
80108b90:	83 ca 0a             	or     $0xa,%edx
80108b93:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b9c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108ba3:	83 ca 10             	or     $0x10,%edx
80108ba6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108baf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108bb6:	83 ca 60             	or     $0x60,%edx
80108bb9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bc2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108bc9:	83 ca 80             	or     $0xffffff80,%edx
80108bcc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108bdc:	83 ca 0f             	or     $0xf,%edx
80108bdf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108bef:	83 e2 ef             	and    $0xffffffef,%edx
80108bf2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bfb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108c02:	83 e2 df             	and    $0xffffffdf,%edx
80108c05:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c0e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108c15:	83 ca 40             	or     $0x40,%edx
80108c18:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c21:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108c28:	83 ca 80             	or     $0xffffff80,%edx
80108c2b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c34:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3e:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108c45:	ff ff 
80108c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c4a:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108c51:	00 00 
80108c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c56:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c60:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108c67:	83 e2 f0             	and    $0xfffffff0,%edx
80108c6a:	83 ca 02             	or     $0x2,%edx
80108c6d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c76:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108c7d:	83 ca 10             	or     $0x10,%edx
80108c80:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c89:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108c90:	83 ca 60             	or     $0x60,%edx
80108c93:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108ca3:	83 ca 80             	or     $0xffffff80,%edx
80108ca6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108caf:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108cb6:	83 ca 0f             	or     $0xf,%edx
80108cb9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc2:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108cc9:	83 e2 ef             	and    $0xffffffef,%edx
80108ccc:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd5:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108cdc:	83 e2 df             	and    $0xffffffdf,%edx
80108cdf:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108cef:	83 ca 40             	or     $0x40,%edx
80108cf2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cfb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108d02:	83 ca 80             	or     $0xffffff80,%edx
80108d05:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d0e:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d18:	05 b4 00 00 00       	add    $0xb4,%eax
80108d1d:	89 c3                	mov    %eax,%ebx
80108d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d22:	05 b4 00 00 00       	add    $0xb4,%eax
80108d27:	c1 e8 10             	shr    $0x10,%eax
80108d2a:	89 c1                	mov    %eax,%ecx
80108d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d2f:	05 b4 00 00 00       	add    $0xb4,%eax
80108d34:	c1 e8 18             	shr    $0x18,%eax
80108d37:	89 c2                	mov    %eax,%edx
80108d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d3c:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108d43:	00 00 
80108d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d48:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d52:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80108d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5b:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108d62:	83 e1 f0             	and    $0xfffffff0,%ecx
80108d65:	83 c9 02             	or     $0x2,%ecx
80108d68:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d71:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108d78:	83 c9 10             	or     $0x10,%ecx
80108d7b:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d84:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108d8b:	83 e1 9f             	and    $0xffffff9f,%ecx
80108d8e:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d97:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108d9e:	83 c9 80             	or     $0xffffff80,%ecx
80108da1:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108daa:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108db1:	83 e1 f0             	and    $0xfffffff0,%ecx
80108db4:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dbd:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108dc4:	83 e1 ef             	and    $0xffffffef,%ecx
80108dc7:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd0:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108dd7:	83 e1 df             	and    $0xffffffdf,%ecx
80108dda:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de3:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108dea:	83 c9 40             	or     $0x40,%ecx
80108ded:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108df6:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108dfd:	83 c9 80             	or     $0xffffff80,%ecx
80108e00:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e09:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e12:	83 c0 70             	add    $0x70,%eax
80108e15:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108e1c:	00 
80108e1d:	89 04 24             	mov    %eax,(%esp)
80108e20:	e8 37 fb ff ff       	call   8010895c <lgdt>
  loadgs(SEG_KCPU << 3);
80108e25:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108e2c:	e8 6a fb ff ff       	call   8010899b <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80108e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e34:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108e3a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108e41:	00 00 00 00 
}
80108e45:	83 c4 24             	add    $0x24,%esp
80108e48:	5b                   	pop    %ebx
80108e49:	5d                   	pop    %ebp
80108e4a:	c3                   	ret    

80108e4b <walkpgdir>:
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
//static 
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108e4b:	55                   	push   %ebp
80108e4c:	89 e5                	mov    %esp,%ebp
80108e4e:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108e51:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e54:	c1 e8 16             	shr    $0x16,%eax
80108e57:	c1 e0 02             	shl    $0x2,%eax
80108e5a:	03 45 08             	add    0x8(%ebp),%eax
80108e5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e63:	8b 00                	mov    (%eax),%eax
80108e65:	83 e0 01             	and    $0x1,%eax
80108e68:	84 c0                	test   %al,%al
80108e6a:	74 17                	je     80108e83 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6f:	8b 00                	mov    (%eax),%eax
80108e71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e76:	89 04 24             	mov    %eax,(%esp)
80108e79:	e8 4a fb ff ff       	call   801089c8 <p2v>
80108e7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108e81:	eb 4b                	jmp    80108ece <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108e83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108e87:	74 0e                	je     80108e97 <walkpgdir+0x4c>
80108e89:	e8 65 9c ff ff       	call   80102af3 <kalloc>
80108e8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108e91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108e95:	75 07                	jne    80108e9e <walkpgdir+0x53>
      return 0;
80108e97:	b8 00 00 00 00       	mov    $0x0,%eax
80108e9c:	eb 41                	jmp    80108edf <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108e9e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ea5:	00 
80108ea6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108ead:	00 
80108eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108eb1:	89 04 24             	mov    %eax,(%esp)
80108eb4:	e8 ad d3 ff ff       	call   80106266 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ebc:	89 04 24             	mov    %eax,(%esp)
80108ebf:	e8 f7 fa ff ff       	call   801089bb <v2p>
80108ec4:	89 c2                	mov    %eax,%edx
80108ec6:	83 ca 07             	or     $0x7,%edx
80108ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ecc:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108ece:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ed1:	c1 e8 0c             	shr    $0xc,%eax
80108ed4:	25 ff 03 00 00       	and    $0x3ff,%eax
80108ed9:	c1 e0 02             	shl    $0x2,%eax
80108edc:	03 45 f4             	add    -0xc(%ebp),%eax
}
80108edf:	c9                   	leave  
80108ee0:	c3                   	ret    

80108ee1 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108ee1:	55                   	push   %ebp
80108ee2:	89 e5                	mov    %esp,%ebp
80108ee4:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ef5:	03 45 10             	add    0x10(%ebp),%eax
80108ef8:	83 e8 01             	sub    $0x1,%eax
80108efb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108f03:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108f0a:	00 
80108f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f12:	8b 45 08             	mov    0x8(%ebp),%eax
80108f15:	89 04 24             	mov    %eax,(%esp)
80108f18:	e8 2e ff ff ff       	call   80108e4b <walkpgdir>
80108f1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f20:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f24:	75 07                	jne    80108f2d <mappages+0x4c>
      return -1;
80108f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108f2b:	eb 46                	jmp    80108f73 <mappages+0x92>
    if(*pte & PTE_P)
80108f2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f30:	8b 00                	mov    (%eax),%eax
80108f32:	83 e0 01             	and    $0x1,%eax
80108f35:	84 c0                	test   %al,%al
80108f37:	74 0c                	je     80108f45 <mappages+0x64>
      panic("remap");
80108f39:	c7 04 24 60 9f 10 80 	movl   $0x80109f60,(%esp)
80108f40:	e8 f8 75 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108f45:	8b 45 18             	mov    0x18(%ebp),%eax
80108f48:	0b 45 14             	or     0x14(%ebp),%eax
80108f4b:	89 c2                	mov    %eax,%edx
80108f4d:	83 ca 01             	or     $0x1,%edx
80108f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f53:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f58:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108f5b:	74 10                	je     80108f6d <mappages+0x8c>
      break;
    a += PGSIZE;
80108f5d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108f64:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108f6b:	eb 96                	jmp    80108f03 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108f6d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108f6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f73:	c9                   	leave  
80108f74:	c3                   	ret    

80108f75 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm()
{
80108f75:	55                   	push   %ebp
80108f76:	89 e5                	mov    %esp,%ebp
80108f78:	53                   	push   %ebx
80108f79:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108f7c:	e8 72 9b ff ff       	call   80102af3 <kalloc>
80108f81:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f88:	75 0a                	jne    80108f94 <setupkvm+0x1f>
    return 0;
80108f8a:	b8 00 00 00 00       	mov    $0x0,%eax
80108f8f:	e9 98 00 00 00       	jmp    8010902c <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80108f94:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108f9b:	00 
80108f9c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108fa3:	00 
80108fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa7:	89 04 24             	mov    %eax,(%esp)
80108faa:	e8 b7 d2 ff ff       	call   80106266 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108faf:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80108fb6:	e8 0d fa ff ff       	call   801089c8 <p2v>
80108fbb:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108fc0:	76 0c                	jbe    80108fce <setupkvm+0x59>
    panic("PHYSTOP too high");
80108fc2:	c7 04 24 66 9f 10 80 	movl   $0x80109f66,(%esp)
80108fc9:	e8 6f 75 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108fce:	c7 45 f4 00 d5 10 80 	movl   $0x8010d500,-0xc(%ebp)
80108fd5:	eb 49                	jmp    80109020 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80108fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108fda:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108fe0:	8b 50 04             	mov    0x4(%eax),%edx
80108fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe6:	8b 58 08             	mov    0x8(%eax),%ebx
80108fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fec:	8b 40 04             	mov    0x4(%eax),%eax
80108fef:	29 c3                	sub    %eax,%ebx
80108ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff4:	8b 00                	mov    (%eax),%eax
80108ff6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108ffa:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108ffe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80109002:	89 44 24 04          	mov    %eax,0x4(%esp)
80109006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109009:	89 04 24             	mov    %eax,(%esp)
8010900c:	e8 d0 fe ff ff       	call   80108ee1 <mappages>
80109011:	85 c0                	test   %eax,%eax
80109013:	79 07                	jns    8010901c <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80109015:	b8 00 00 00 00       	mov    $0x0,%eax
8010901a:	eb 10                	jmp    8010902c <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010901c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80109020:	81 7d f4 40 d5 10 80 	cmpl   $0x8010d540,-0xc(%ebp)
80109027:	72 ae                	jb     80108fd7 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80109029:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010902c:	83 c4 34             	add    $0x34,%esp
8010902f:	5b                   	pop    %ebx
80109030:	5d                   	pop    %ebp
80109031:	c3                   	ret    

80109032 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80109032:	55                   	push   %ebp
80109033:	89 e5                	mov    %esp,%ebp
80109035:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80109038:	e8 38 ff ff ff       	call   80108f75 <setupkvm>
8010903d:	a3 98 7a 18 80       	mov    %eax,0x80187a98
  switchkvm();
80109042:	e8 02 00 00 00       	call   80109049 <switchkvm>
}
80109047:	c9                   	leave  
80109048:	c3                   	ret    

80109049 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80109049:	55                   	push   %ebp
8010904a:	89 e5                	mov    %esp,%ebp
8010904c:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010904f:	a1 98 7a 18 80       	mov    0x80187a98,%eax
80109054:	89 04 24             	mov    %eax,(%esp)
80109057:	e8 5f f9 ff ff       	call   801089bb <v2p>
8010905c:	89 04 24             	mov    %eax,(%esp)
8010905f:	e8 4c f9 ff ff       	call   801089b0 <lcr3>
}
80109064:	c9                   	leave  
80109065:	c3                   	ret    

80109066 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80109066:	55                   	push   %ebp
80109067:	89 e5                	mov    %esp,%ebp
80109069:	53                   	push   %ebx
8010906a:	83 ec 14             	sub    $0x14,%esp
  pushcli();
8010906d:	e8 ef d0 ff ff       	call   80106161 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80109072:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109078:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010907f:	83 c2 08             	add    $0x8,%edx
80109082:	89 d3                	mov    %edx,%ebx
80109084:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010908b:	83 c2 08             	add    $0x8,%edx
8010908e:	c1 ea 10             	shr    $0x10,%edx
80109091:	89 d1                	mov    %edx,%ecx
80109093:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010909a:	83 c2 08             	add    $0x8,%edx
8010909d:	c1 ea 18             	shr    $0x18,%edx
801090a0:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801090a7:	67 00 
801090a9:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801090b0:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801090b6:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801090bd:	83 e1 f0             	and    $0xfffffff0,%ecx
801090c0:	83 c9 09             	or     $0x9,%ecx
801090c3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801090c9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801090d0:	83 c9 10             	or     $0x10,%ecx
801090d3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801090d9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801090e0:	83 e1 9f             	and    $0xffffff9f,%ecx
801090e3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801090e9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801090f0:	83 c9 80             	or     $0xffffff80,%ecx
801090f3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801090f9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80109100:	83 e1 f0             	and    $0xfffffff0,%ecx
80109103:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80109109:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80109110:	83 e1 ef             	and    $0xffffffef,%ecx
80109113:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80109119:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80109120:	83 e1 df             	and    $0xffffffdf,%ecx
80109123:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80109129:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80109130:	83 c9 40             	or     $0x40,%ecx
80109133:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80109139:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80109140:	83 e1 7f             	and    $0x7f,%ecx
80109143:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80109149:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010914f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109155:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010915c:	83 e2 ef             	and    $0xffffffef,%edx
8010915f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80109165:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010916b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80109171:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80109177:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010917e:	8b 52 08             	mov    0x8(%edx),%edx
80109181:	81 c2 00 10 00 00    	add    $0x1000,%edx
80109187:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010918a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80109191:	e8 ef f7 ff ff       	call   80108985 <ltr>
  if(p->pgdir == 0)
80109196:	8b 45 08             	mov    0x8(%ebp),%eax
80109199:	8b 40 04             	mov    0x4(%eax),%eax
8010919c:	85 c0                	test   %eax,%eax
8010919e:	75 0c                	jne    801091ac <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801091a0:	c7 04 24 77 9f 10 80 	movl   $0x80109f77,(%esp)
801091a7:	e8 91 73 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801091ac:	8b 45 08             	mov    0x8(%ebp),%eax
801091af:	8b 40 04             	mov    0x4(%eax),%eax
801091b2:	89 04 24             	mov    %eax,(%esp)
801091b5:	e8 01 f8 ff ff       	call   801089bb <v2p>
801091ba:	89 04 24             	mov    %eax,(%esp)
801091bd:	e8 ee f7 ff ff       	call   801089b0 <lcr3>
  popcli();
801091c2:	e8 e2 cf ff ff       	call   801061a9 <popcli>
}
801091c7:	83 c4 14             	add    $0x14,%esp
801091ca:	5b                   	pop    %ebx
801091cb:	5d                   	pop    %ebp
801091cc:	c3                   	ret    

801091cd <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801091cd:	55                   	push   %ebp
801091ce:	89 e5                	mov    %esp,%ebp
801091d0:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801091d3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801091da:	76 0c                	jbe    801091e8 <inituvm+0x1b>
    panic("inituvm: more than a page");
801091dc:	c7 04 24 8b 9f 10 80 	movl   $0x80109f8b,(%esp)
801091e3:	e8 55 73 ff ff       	call   8010053d <panic>
  mem = kalloc();
801091e8:	e8 06 99 ff ff       	call   80102af3 <kalloc>
801091ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801091f0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801091f7:	00 
801091f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801091ff:	00 
80109200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109203:	89 04 24             	mov    %eax,(%esp)
80109206:	e8 5b d0 ff ff       	call   80106266 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010920b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010920e:	89 04 24             	mov    %eax,(%esp)
80109211:	e8 a5 f7 ff ff       	call   801089bb <v2p>
80109216:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010921d:	00 
8010921e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80109222:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109229:	00 
8010922a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80109231:	00 
80109232:	8b 45 08             	mov    0x8(%ebp),%eax
80109235:	89 04 24             	mov    %eax,(%esp)
80109238:	e8 a4 fc ff ff       	call   80108ee1 <mappages>
  memmove(mem, init, sz);
8010923d:	8b 45 10             	mov    0x10(%ebp),%eax
80109240:	89 44 24 08          	mov    %eax,0x8(%esp)
80109244:	8b 45 0c             	mov    0xc(%ebp),%eax
80109247:	89 44 24 04          	mov    %eax,0x4(%esp)
8010924b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010924e:	89 04 24             	mov    %eax,(%esp)
80109251:	e8 e3 d0 ff ff       	call   80106339 <memmove>
}
80109256:	c9                   	leave  
80109257:	c3                   	ret    

80109258 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80109258:	55                   	push   %ebp
80109259:	89 e5                	mov    %esp,%ebp
8010925b:	53                   	push   %ebx
8010925c:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010925f:	8b 45 0c             	mov    0xc(%ebp),%eax
80109262:	25 ff 0f 00 00       	and    $0xfff,%eax
80109267:	85 c0                	test   %eax,%eax
80109269:	74 0c                	je     80109277 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010926b:	c7 04 24 a8 9f 10 80 	movl   $0x80109fa8,(%esp)
80109272:	e8 c6 72 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80109277:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010927e:	e9 ad 00 00 00       	jmp    80109330 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80109283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109286:	8b 55 0c             	mov    0xc(%ebp),%edx
80109289:	01 d0                	add    %edx,%eax
8010928b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80109292:	00 
80109293:	89 44 24 04          	mov    %eax,0x4(%esp)
80109297:	8b 45 08             	mov    0x8(%ebp),%eax
8010929a:	89 04 24             	mov    %eax,(%esp)
8010929d:	e8 a9 fb ff ff       	call   80108e4b <walkpgdir>
801092a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801092a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801092a9:	75 0c                	jne    801092b7 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801092ab:	c7 04 24 cb 9f 10 80 	movl   $0x80109fcb,(%esp)
801092b2:	e8 86 72 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801092b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092ba:	8b 00                	mov    (%eax),%eax
801092bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801092c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092c7:	8b 55 18             	mov    0x18(%ebp),%edx
801092ca:	89 d1                	mov    %edx,%ecx
801092cc:	29 c1                	sub    %eax,%ecx
801092ce:	89 c8                	mov    %ecx,%eax
801092d0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801092d5:	77 11                	ja     801092e8 <loaduvm+0x90>
      n = sz - i;
801092d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092da:	8b 55 18             	mov    0x18(%ebp),%edx
801092dd:	89 d1                	mov    %edx,%ecx
801092df:	29 c1                	sub    %eax,%ecx
801092e1:	89 c8                	mov    %ecx,%eax
801092e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801092e6:	eb 07                	jmp    801092ef <loaduvm+0x97>
    else
      n = PGSIZE;
801092e8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801092ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801092f2:	8b 55 14             	mov    0x14(%ebp),%edx
801092f5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801092f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092fb:	89 04 24             	mov    %eax,(%esp)
801092fe:	e8 c5 f6 ff ff       	call   801089c8 <p2v>
80109303:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109306:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010930a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010930e:	89 44 24 04          	mov    %eax,0x4(%esp)
80109312:	8b 45 10             	mov    0x10(%ebp),%eax
80109315:	89 04 24             	mov    %eax,(%esp)
80109318:	e8 41 8a ff ff       	call   80101d5e <readi>
8010931d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80109320:	74 07                	je     80109329 <loaduvm+0xd1>
      return -1;
80109322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109327:	eb 18                	jmp    80109341 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80109329:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109333:	3b 45 18             	cmp    0x18(%ebp),%eax
80109336:	0f 82 47 ff ff ff    	jb     80109283 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010933c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109341:	83 c4 24             	add    $0x24,%esp
80109344:	5b                   	pop    %ebx
80109345:	5d                   	pop    %ebp
80109346:	c3                   	ret    

80109347 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109347:	55                   	push   %ebp
80109348:	89 e5                	mov    %esp,%ebp
8010934a:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010934d:	8b 45 10             	mov    0x10(%ebp),%eax
80109350:	85 c0                	test   %eax,%eax
80109352:	79 0a                	jns    8010935e <allocuvm+0x17>
    return 0;
80109354:	b8 00 00 00 00       	mov    $0x0,%eax
80109359:	e9 b5 00 00 00       	jmp    80109413 <allocuvm+0xcc>
  if(newsz < oldsz)
8010935e:	8b 45 10             	mov    0x10(%ebp),%eax
80109361:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109364:	73 08                	jae    8010936e <allocuvm+0x27>
    return oldsz;
80109366:	8b 45 0c             	mov    0xc(%ebp),%eax
80109369:	e9 a5 00 00 00       	jmp    80109413 <allocuvm+0xcc>

  a = PGROUNDUP(oldsz);
8010936e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109371:	05 ff 0f 00 00       	add    $0xfff,%eax
80109376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010937b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010937e:	e9 81 00 00 00       	jmp    80109404 <allocuvm+0xbd>
    mem = kalloc();
80109383:	e8 6b 97 ff ff       	call   80102af3 <kalloc>
80109388:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010938b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010938f:	75 20                	jne    801093b1 <allocuvm+0x6a>
      //cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
80109391:	8b 45 0c             	mov    0xc(%ebp),%eax
80109394:	89 44 24 08          	mov    %eax,0x8(%esp)
80109398:	8b 45 10             	mov    0x10(%ebp),%eax
8010939b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010939f:	8b 45 08             	mov    0x8(%ebp),%eax
801093a2:	89 04 24             	mov    %eax,(%esp)
801093a5:	e8 6b 00 00 00       	call   80109415 <deallocuvm>
      return 0;
801093aa:	b8 00 00 00 00       	mov    $0x0,%eax
801093af:	eb 62                	jmp    80109413 <allocuvm+0xcc>
    }
    memset(mem, 0, PGSIZE);
801093b1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801093b8:	00 
801093b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801093c0:	00 
801093c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093c4:	89 04 24             	mov    %eax,(%esp)
801093c7:	e8 9a ce ff ff       	call   80106266 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801093cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093cf:	89 04 24             	mov    %eax,(%esp)
801093d2:	e8 e4 f5 ff ff       	call   801089bb <v2p>
801093d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093da:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801093e1:	00 
801093e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
801093e6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801093ed:	00 
801093ee:	89 54 24 04          	mov    %edx,0x4(%esp)
801093f2:	8b 45 08             	mov    0x8(%ebp),%eax
801093f5:	89 04 24             	mov    %eax,(%esp)
801093f8:	e8 e4 fa ff ff       	call   80108ee1 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801093fd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109407:	3b 45 10             	cmp    0x10(%ebp),%eax
8010940a:	0f 82 73 ff ff ff    	jb     80109383 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80109410:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109413:	c9                   	leave  
80109414:	c3                   	ret    

80109415 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80109415:	55                   	push   %ebp
80109416:	89 e5                	mov    %esp,%ebp
80109418:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010941b:	8b 45 10             	mov    0x10(%ebp),%eax
8010941e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109421:	72 08                	jb     8010942b <deallocuvm+0x16>
    return oldsz;
80109423:	8b 45 0c             	mov    0xc(%ebp),%eax
80109426:	e9 a4 00 00 00       	jmp    801094cf <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010942b:	8b 45 10             	mov    0x10(%ebp),%eax
8010942e:	05 ff 0f 00 00       	add    $0xfff,%eax
80109433:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109438:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010943b:	e9 80 00 00 00       	jmp    801094c0 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109443:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010944a:	00 
8010944b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010944f:	8b 45 08             	mov    0x8(%ebp),%eax
80109452:	89 04 24             	mov    %eax,(%esp)
80109455:	e8 f1 f9 ff ff       	call   80108e4b <walkpgdir>
8010945a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010945d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109461:	75 09                	jne    8010946c <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80109463:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010946a:	eb 4d                	jmp    801094b9 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
8010946c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010946f:	8b 00                	mov    (%eax),%eax
80109471:	83 e0 01             	and    $0x1,%eax
80109474:	84 c0                	test   %al,%al
80109476:	74 41                	je     801094b9 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80109478:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010947b:	8b 00                	mov    (%eax),%eax
8010947d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109482:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80109485:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109489:	75 0c                	jne    80109497 <deallocuvm+0x82>
        panic("kfree");
8010948b:	c7 04 24 e9 9f 10 80 	movl   $0x80109fe9,(%esp)
80109492:	e8 a6 70 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80109497:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010949a:	89 04 24             	mov    %eax,(%esp)
8010949d:	e8 26 f5 ff ff       	call   801089c8 <p2v>
801094a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801094a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801094a8:	89 04 24             	mov    %eax,(%esp)
801094ab:	e8 aa 95 ff ff       	call   80102a5a <kfree>
      *pte = 0;
801094b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801094b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801094b9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801094c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801094c6:	0f 82 74 ff ff ff    	jb     80109440 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801094cc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801094cf:	c9                   	leave  
801094d0:	c3                   	ret    

801094d1 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801094d1:	55                   	push   %ebp
801094d2:	89 e5                	mov    %esp,%ebp
801094d4:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801094d7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801094db:	75 0c                	jne    801094e9 <freevm+0x18>
    panic("freevm: no pgdir");
801094dd:	c7 04 24 ef 9f 10 80 	movl   $0x80109fef,(%esp)
801094e4:	e8 54 70 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801094e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801094f0:	00 
801094f1:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801094f8:	80 
801094f9:	8b 45 08             	mov    0x8(%ebp),%eax
801094fc:	89 04 24             	mov    %eax,(%esp)
801094ff:	e8 11 ff ff ff       	call   80109415 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80109504:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010950b:	eb 3c                	jmp    80109549 <freevm+0x78>
    if(pgdir[i] & PTE_P){
8010950d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109510:	c1 e0 02             	shl    $0x2,%eax
80109513:	03 45 08             	add    0x8(%ebp),%eax
80109516:	8b 00                	mov    (%eax),%eax
80109518:	83 e0 01             	and    $0x1,%eax
8010951b:	84 c0                	test   %al,%al
8010951d:	74 26                	je     80109545 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010951f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109522:	c1 e0 02             	shl    $0x2,%eax
80109525:	03 45 08             	add    0x8(%ebp),%eax
80109528:	8b 00                	mov    (%eax),%eax
8010952a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010952f:	89 04 24             	mov    %eax,(%esp)
80109532:	e8 91 f4 ff ff       	call   801089c8 <p2v>
80109537:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010953a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010953d:	89 04 24             	mov    %eax,(%esp)
80109540:	e8 15 95 ff ff       	call   80102a5a <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80109545:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109549:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109550:	76 bb                	jbe    8010950d <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80109552:	8b 45 08             	mov    0x8(%ebp),%eax
80109555:	89 04 24             	mov    %eax,(%esp)
80109558:	e8 fd 94 ff ff       	call   80102a5a <kfree>
}
8010955d:	c9                   	leave  
8010955e:	c3                   	ret    

8010955f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010955f:	55                   	push   %ebp
80109560:	89 e5                	mov    %esp,%ebp
80109562:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109565:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010956c:	00 
8010956d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109570:	89 44 24 04          	mov    %eax,0x4(%esp)
80109574:	8b 45 08             	mov    0x8(%ebp),%eax
80109577:	89 04 24             	mov    %eax,(%esp)
8010957a:	e8 cc f8 ff ff       	call   80108e4b <walkpgdir>
8010957f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109582:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109586:	75 0c                	jne    80109594 <clearpteu+0x35>
    panic("clearpteu");
80109588:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
8010958f:	e8 a9 6f ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80109594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109597:	8b 00                	mov    (%eax),%eax
80109599:	89 c2                	mov    %eax,%edx
8010959b:	83 e2 fb             	and    $0xfffffffb,%edx
8010959e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a1:	89 10                	mov    %edx,(%eax)
}
801095a3:	c9                   	leave  
801095a4:	c3                   	ret    

801095a5 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801095a5:	55                   	push   %ebp
801095a6:	89 e5                	mov    %esp,%ebp
801095a8:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
801095ab:	e8 c5 f9 ff ff       	call   80108f75 <setupkvm>
801095b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801095b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801095b7:	75 0a                	jne    801095c3 <copyuvm+0x1e>
    return 0;
801095b9:	b8 00 00 00 00       	mov    $0x0,%eax
801095be:	e9 f1 00 00 00       	jmp    801096b4 <copyuvm+0x10f>
  for(i = 0; i < sz; i += PGSIZE){
801095c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801095ca:	e9 c0 00 00 00       	jmp    8010968f <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801095cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801095d9:	00 
801095da:	89 44 24 04          	mov    %eax,0x4(%esp)
801095de:	8b 45 08             	mov    0x8(%ebp),%eax
801095e1:	89 04 24             	mov    %eax,(%esp)
801095e4:	e8 62 f8 ff ff       	call   80108e4b <walkpgdir>
801095e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801095ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801095f0:	75 0c                	jne    801095fe <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801095f2:	c7 04 24 0a a0 10 80 	movl   $0x8010a00a,(%esp)
801095f9:	e8 3f 6f ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801095fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109601:	8b 00                	mov    (%eax),%eax
80109603:	83 e0 01             	and    $0x1,%eax
80109606:	85 c0                	test   %eax,%eax
80109608:	75 0c                	jne    80109616 <copyuvm+0x71>
      panic("copyuvm: page not present");
8010960a:	c7 04 24 24 a0 10 80 	movl   $0x8010a024,(%esp)
80109611:	e8 27 6f ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80109616:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109619:	8b 00                	mov    (%eax),%eax
8010961b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109620:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((mem = kalloc()) == 0)
80109623:	e8 cb 94 ff ff       	call   80102af3 <kalloc>
80109628:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010962b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010962f:	74 6f                	je     801096a0 <copyuvm+0xfb>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80109631:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109634:	89 04 24             	mov    %eax,(%esp)
80109637:	e8 8c f3 ff ff       	call   801089c8 <p2v>
8010963c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109643:	00 
80109644:	89 44 24 04          	mov    %eax,0x4(%esp)
80109648:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010964b:	89 04 24             	mov    %eax,(%esp)
8010964e:	e8 e6 cc ff ff       	call   80106339 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
80109653:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109656:	89 04 24             	mov    %eax,(%esp)
80109659:	e8 5d f3 ff ff       	call   801089bb <v2p>
8010965e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109661:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80109668:	00 
80109669:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010966d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80109674:	00 
80109675:	89 54 24 04          	mov    %edx,0x4(%esp)
80109679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010967c:	89 04 24             	mov    %eax,(%esp)
8010967f:	e8 5d f8 ff ff       	call   80108ee1 <mappages>
80109684:	85 c0                	test   %eax,%eax
80109686:	78 1b                	js     801096a3 <copyuvm+0xfe>
  uint pa, i;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80109688:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010968f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109692:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109695:	0f 82 34 ff ff ff    	jb     801095cf <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
  }
  return d;
8010969b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010969e:	eb 14                	jmp    801096b4 <copyuvm+0x10f>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801096a0:	90                   	nop
801096a1:	eb 01                	jmp    801096a4 <copyuvm+0xff>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), PTE_W|PTE_U) < 0)
      goto bad;
801096a3:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801096a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096a7:	89 04 24             	mov    %eax,(%esp)
801096aa:	e8 22 fe ff ff       	call   801094d1 <freevm>
  return 0;
801096af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801096b4:	c9                   	leave  
801096b5:	c3                   	ret    

801096b6 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801096b6:	55                   	push   %ebp
801096b7:	89 e5                	mov    %esp,%ebp
801096b9:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801096bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801096c3:	00 
801096c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801096c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801096cb:	8b 45 08             	mov    0x8(%ebp),%eax
801096ce:	89 04 24             	mov    %eax,(%esp)
801096d1:	e8 75 f7 ff ff       	call   80108e4b <walkpgdir>
801096d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801096d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096dc:	8b 00                	mov    (%eax),%eax
801096de:	83 e0 01             	and    $0x1,%eax
801096e1:	85 c0                	test   %eax,%eax
801096e3:	75 07                	jne    801096ec <uva2ka+0x36>
    return 0;
801096e5:	b8 00 00 00 00       	mov    $0x0,%eax
801096ea:	eb 25                	jmp    80109711 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801096ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ef:	8b 00                	mov    (%eax),%eax
801096f1:	83 e0 04             	and    $0x4,%eax
801096f4:	85 c0                	test   %eax,%eax
801096f6:	75 07                	jne    801096ff <uva2ka+0x49>
    return 0;
801096f8:	b8 00 00 00 00       	mov    $0x0,%eax
801096fd:	eb 12                	jmp    80109711 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801096ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109702:	8b 00                	mov    (%eax),%eax
80109704:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109709:	89 04 24             	mov    %eax,(%esp)
8010970c:	e8 b7 f2 ff ff       	call   801089c8 <p2v>
}
80109711:	c9                   	leave  
80109712:	c3                   	ret    

80109713 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109713:	55                   	push   %ebp
80109714:	89 e5                	mov    %esp,%ebp
80109716:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;
  buf = (char*)p;
80109719:	8b 45 10             	mov    0x10(%ebp),%eax
8010971c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010971f:	e9 8b 00 00 00       	jmp    801097af <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80109724:	8b 45 0c             	mov    0xc(%ebp),%eax
80109727:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010972c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010972f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109732:	89 44 24 04          	mov    %eax,0x4(%esp)
80109736:	8b 45 08             	mov    0x8(%ebp),%eax
80109739:	89 04 24             	mov    %eax,(%esp)
8010973c:	e8 75 ff ff ff       	call   801096b6 <uva2ka>
80109741:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109744:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109748:	75 07                	jne    80109751 <copyout+0x3e>
      return -1;
8010974a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010974f:	eb 6d                	jmp    801097be <copyout+0xab>
    n = PGSIZE - (va - va0);
80109751:	8b 45 0c             	mov    0xc(%ebp),%eax
80109754:	8b 55 ec             	mov    -0x14(%ebp),%edx
80109757:	89 d1                	mov    %edx,%ecx
80109759:	29 c1                	sub    %eax,%ecx
8010975b:	89 c8                	mov    %ecx,%eax
8010975d:	05 00 10 00 00       	add    $0x1000,%eax
80109762:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109768:	3b 45 14             	cmp    0x14(%ebp),%eax
8010976b:	76 06                	jbe    80109773 <copyout+0x60>
      n = len;
8010976d:	8b 45 14             	mov    0x14(%ebp),%eax
80109770:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109773:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109776:	8b 55 0c             	mov    0xc(%ebp),%edx
80109779:	89 d1                	mov    %edx,%ecx
8010977b:	29 c1                	sub    %eax,%ecx
8010977d:	89 c8                	mov    %ecx,%eax
8010977f:	03 45 e8             	add    -0x18(%ebp),%eax
80109782:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109785:	89 54 24 08          	mov    %edx,0x8(%esp)
80109789:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010978c:	89 54 24 04          	mov    %edx,0x4(%esp)
80109790:	89 04 24             	mov    %eax,(%esp)
80109793:	e8 a1 cb ff ff       	call   80106339 <memmove>
    len -= n;
80109798:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010979b:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010979e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801097a1:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801097a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097a7:	05 00 10 00 00       	add    $0x1000,%eax
801097ac:	89 45 0c             	mov    %eax,0xc(%ebp)
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
  char *buf, *pa0;
  uint n, va0;
  buf = (char*)p;
  while(len > 0){
801097af:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801097b3:	0f 85 6b ff ff ff    	jne    80109724 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801097b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801097be:	c9                   	leave  
801097bf:	c3                   	ret    
