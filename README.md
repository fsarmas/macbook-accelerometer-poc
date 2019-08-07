# MacBook accelerometer proof of concept

## Why this?

Back in the good old days of university, I bought my very first laptop with the first kind-of-salary I ever earned.
It was one of those white, plastic-made first-gen Macbook's. It came equipped with an accelerometer (a.k.a. sudden
motion sensor) which, in Linux (yep, I installed a Linux distro on my Mac) was accessible by reading the file
`/sys/devices/platform/applesmc.768/position`.

So I wrote a couple of simple games just to impress my friends by tilting the laptop around and watching things move.

## How to run the games?

Couldn't be easier. Assuming you have Perl installed:

```
# 1. Guide the ball through the gaps all the way to the bottom
perl gaps.pl

# 2. Try to kill as much enemies as possible
perl spaceship.pl
```

## Do I really need a 2000s laptop to try this out?

Modern Mac's come with SSD so there's no need for an accelerometer anymore. Even I don't have that old Macbook anymore.
Still, you can try these scripts by running `test.pl` script in parallel. Just provide a filename were data will be stored
in the same format the old Macbook would use. Press left and right arrows to mimic laptop horizontal tilt.

```
perl test.pl /tmp/position
```

And run the games providing an argument, which is the same file that `test.pl` is writing. The test and the game should run in
parallel, so run them in two separate virtual terminals.

```
perl gaps.pl /tmp/position

# or

perl spaceship.pl /tmp/position
```
