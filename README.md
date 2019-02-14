# Hello!

I appreciate your interest in LogCheck and I've tried to design a test
that is both fair, interesting, and respectful of your time. If I've
fallen short of that goal, write to me at ben@logcheck.com.

# About this test

At LogCheck, we try to hold ourselves to a high standard of quality
through peer code review: all git branches must be approved by someone
else on the team before they can be merged into the master branch.

This test is meant to simulate that process while assessing your
ability to work with Objective-C code on iOS. You'll be asked to
perform some work on an app, commit your changes in git, and submit
them for review. A LogCheck team member will review both your commit
log and final product, and send you feedback.

An included script will prepare a local git repository. To avoid
reviewer bias, your name and email will be stored in a scrambled form,
and a UUID will be assigned to you so that the reviewer will not know
your identity.

*This is meant to be a fair test.* There are no tricks and no
surprises. (At least, none are intended.) We've tried our best to be
clear. We will not award extra credit for doing stuff we didn't ask
you to do, no matter how clever it is.

There's no hard time limit, but *try not to spend more than three
hours on this.* We want to respect your time. If you haven't finished
after three hours, we encourage you to submit what you have and use
our feedback form to let us know.

## If something goes wrong...

If you have any questions about these instructions, or if something
fails to work as described, please email me at ben@logcheck.com and
I'll do my best to correct the problem and help you out.

## Before you begin

We recommend that you *read this whole document*, and `DITHERING.md`,
before you begin working. It will be easier to understand the code if
you familiarize yourself with the concepts behind error diffusion
dithering. That said, don't stress out: we're not expecting you to
invent a new dithering technique.

# The Test

## The Scenario

Congratulations! You've been hired by DitherCo to work on their
popular image-processing app, Ditherer.

Ditherer is a mobile app that converts beautiful, full-color images
into low-res black-and-white images suitable for display on a monitor
from the mid-1980s or for printing on a fax machine.

Using the app, you select an image from your Photo Library, and within
milliseconds you'll see a black-and-white version. The app also allows
you to select the particular dithering algorithm to use.

A picture is worth 1024 words! Take a moment to open the project, run
the app in the Simulator, and play around with it.

*Pro Tip:* If you get bored with the stock images, you can add new
ones to the Simulator by using Safari to do an image search. Tap and
hold to save a photo the library.

For your first assignment, DitherCo wants you to add a new dithering
algorithm to the existing three choices. However, because they have
big plans for the future of the app, they want you to clean up the
code instead of just hacking a new option into the menu.

## Getting Started

When you're ready to begin, open a Terminal window, navigate to the
project directory, and run the `begin-work.sh` script. The script will
prompt you for your name and email address, assign a UUID to you, and
then create a local git repository to track your changes.

To conceal your identity from the reviewer, the script will configure
the repository to use the UUID in place of your name and email
address. (Don't worry, your global git configuration will not be
modified.)

A scrambled form of your name and email address will be stored in the
initial commit message.

## What You Need To Do

### Part 1. Memory Leak

The DitherCo QA team insists that Ditherer always crashes after a long
testing session. The crash reports indicate that the device is out of
memory.

Find and fix any memory leaks. (Hint: use Xcode's static analyzer to
find them.)

After you fix them, make a commit to the local repository.

Note: Ditherer uses UIImagePickerController, which is known to leak
memory when running on the Simulator. There is nothing you can do
about that, and the QA team doesn't test on the Simulator.

### Part 2. Refactor

The original author of Ditherer put *everything* in the ViewController
class. What a dope! :-(

To prepare for a new dithering algorithm, refactor the code *in order
to make adding or removing algorithms easier*. There may be other ways
to make the code nicer, but keep this goal in mind, plan ahead, and
budget your time accordingly.

You should make at least one commit after you've refactored the code,
but we encourage you to make multiple commits along the way. Think of
the commit messages like brief emails where you can communicate your
thought process to a co-worker.

### Part 3. Add Atkinson Dithering

Bill Atkinson was part of the original Macintosh team and wrote
QuickDraw, MacPaint, and HyperCard. It's a travesty that the dithering
algorithm that he devised isn't one of the options on this app! You'll
soon set that right.

Around 1984, Atkinson devised this error diffusion pattern:

     ...  XXX  1/8  1/8
     1/8  1/8  1/8  ...
     ...  1/8  ...  ...

This grid of numbers means that one-eighth of the error from
converting the pixel at "XXX" should be added to:

* the two pixels to the right of XXX,
* the three nearest pixels in the next line, and
* the pixel directly beneath it, two lines below.

(See `DITHERING.md` for a more in-depth explanation.)

This algorithm is very similar to the existing ones; the primary
difference is the error diffusion pattern. To implement Atkinson
dithering, you should be able to copy some of the existing code and
make a few small changes.

Make at least one final commit after you get Atkinson's algorithm
working.

## Submit Your Work

When you're ready to submit your work, run the `submit-work.sh`
script. Your files will be zipped and uploaded to us. The script will
also open a browser window with a short survey so you can give us
feedback on the test itself.

You can submit multiple times, if necessary. If you forget something
or make a mistake, just run the `submit-work.sh` script again.

That's it! If the upload is successful, there's no need to email us,
but if you don't hear back after a few days, email ben@logcheck.com
with your UUID and ask him what's up.

(The command `git config user.uuid` will display the UUID.)

---

Date: Mon, 11 Feb 2019 21:52:14 -0500
Revision: 03f64be3d40f18a29e65e8c0868611c5485132c4
