<p align="center">
  <img width="200px" src="https://gitcdn.xyz/repo/loklaan/b7e398d15dff9c59d10a9906d596ad8d/raw/5a0c5271242558eb1bd40e7bef5b1b2b17cfa78c/linkaroo.svg" />
</p>

# linkaroo

Is `npm link` or `yarn link` not working for you?

* Does your linked package have **singleton dependencies**, like `react`?
* Maybe your code bundler trips up on **symlinks**?
* Perhaps you're allergic to those commands?

Well, try `linkaroo`.

## Usage

##### First step: pack your package!

```shell
$ cd my-pkg
$ linkaroo pack
#  Packing "my-pkg"... Packed!
#
#  Run the following in your other package or app:
#
#    linkaroo link "my-pkg" "/tmp/linkaroo/my-pkg-1.0.0.tgz"
#    ^ Copied to clipboard. :)
#
#  ...Bai!
```

##### Second step: "link" your pack! (:

```shell
$ cd my-app
$ linkaroo link "my-pkg" "/tmp/linkaroo/my-pkg-0.1.0.tgz"
#  Linking "my-pkg"
#
#    my-pkg-0.1.0.tgz  ⟹   node_modules/my-pkg
#
#  ...Bai!
```

## Problem Background

To avoid problems while using `npm link` during development of interdependent packages, we can pretend to `publish` and `install` while iterations continue.

That's what these two commands pretend to do:
1. `pack` will prepare your package for publish, and put the resulting tarball somewhere safe locally.
2. `link` will unpack that tarball into your other dependants `node_modules/` directory, just like `npm install` does.

## Legal

Thanks to the NPM team for making their CLI easy to use.

MIT
