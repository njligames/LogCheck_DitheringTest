# Color Depth Reduction

Dithering is a technique used to reduce the color depth of an image
without distorting it too much.

For example, consider a grayscale image, where each pixel is stored as
a single byte, with a value between 0 (black) and 255 (white). Each
pixel can be one of 256 possible colors (that's the depth).

Now let's say we wanted to print this image on a black-and-white
printer. There, each pixel must be black (inked) or white (not inked).

A simple approach would be to consider each pixel individually. If it
is closer to black, make it black; if it's closer to white, make it
white. In mathematical terms, if the pixel value is less than 128,
make it 0; otherwise, make it 255. Do that for every pixel in the
image and you'll have a black-and-white version...

...except it will look terrible! Details will be washed out. Most
images will look like messy ink blots. There's got to be a better way!

# Error Diffusion Dithering

The basic idea behind error diffusion is that, when we convert a pixel
to black or white, we're losing some information: that's the error. In
the simple approach, we just threw the error away. In error diffusion,
instead we distribute or "diffuse" the error from one pixels to nearby
pixels, which influences whether they become black or white. As a
result, we preserve more information in the final image even though we
have fewer colors to work with.

For example:

Assume we're scanning an image, one pixel at a time, starting at the
top-left and moving left to right. The current pixel is dark gray
(value 96). Because it's less than 128, we replace it with a black
pixel (0). Since our new color is 96 "steps" away from the original
color, our error is 96.

In 1976, Robert Floyd and Louis Steinberg published a method for
distributing the error to nearby pixels. It can be summarized in this
pattern:

    ....  XXXX  7/16
    3/16  5/16  1/16

"XXXX" is the current pixel. The numbers represent the fraction of the
error that should be added to the pixel to the right and on the next
line. The pixel to the left is "...." because we've already visited it
(we're moving left to right).

Remember that our error value is 96. According to the Floyd-Steinberg
pattern, we would add 7/16 of 96 = 42 to the next pixel, and so on, in
a pattern like this:

    .... XXXX  +42
    +18  +30    +6

Now let's move to the right. If the next pixel is also dark gray (96),
we first add the error (+42) yielding 138. Since that's closer to
white than black, *this* dark gray pixel becomes white. Also, we have
a new error value (-117) to spread around just as we did before.

If we continue to process the whole image this way, we'll get a much
better looking result than if we simply discarded the error. And
that's how you process an image with Floyd-Steinberg dithering!

# Other Error Diffusion Dithering Algorithms

There are many other error diffusion algorithms, but most of them work
in a similar way, using different coefficients, and sometimes looking
at the next *two* lines.

In addition to Floyd-Steinberg, the Ditherer app implements two
others. (And we want you to add a fourth!)

If you'd like to read more about dithering algorithms, and see some
example images, check out [this blog post by Tanner Hellend][1].

[1]: https://www.tannerhelland.com/4660/dithering-eleven-algorithms-source-code/
