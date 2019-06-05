<p align="center">
  <img width="200px" src="https://gitcdn.xyz/repo/loklaan/b7e398d15dff9c59d10a9906d596ad8d/raw/5a0c5271242558eb1bd40e7bef5b1b2b17cfa78c/linkaroo.svg" />
  <sub><em>"g'day"</em></sub>
</p>

# linkaroooooooooooooooooooooooooooooooooooooooooooo

<p align="center">
<strong>Has <code>npm link</code> or <code/>yarn link</code> got you down?</strong> 😃😭
</p>

<p align="center">
Does your linked package have troublesome <strong>"singleton" dependencies</strong> that begin to double-up, like <code>react</code>?
</p>

<p align="center">
Maybe your <strong>code bundler</strong> trips up when traversing weird ol' <strong>symlinks</strong>?
</p>

<p align="center">
Perhaps you're allergic to or straight up <strong>don't trust</strong> those `link` commands? 🤷‍
</p>


<p align="center">
...
</p>


<p align="center">
👉🦘 <strong>Well, give up now and try <code>linkaroo</code>.</strong> 🦘👍😉 wink
</p>

## Install

```shell
npm i -g linkaroo
```

## Usage

### Step 1.

_Paaaaack your package!_

```shell
$ cd my-pkg && npm run build
$ linkaroo pack
```

### Step 2.

_Liiiiiink it up!_

```shell
$ cd my-app
$ linkaroo link "my-pkg@1.0.0"
```

### Step 3.

_Repeat steps 1 & 2 when `my-pkg` chaaaaanges._

<p align="right">
👏 <strong>DONE</strong> 👏
</p>
<p align="right">
👏 <strong>DONE</strong> 👏
</p>
<p align="right">
<sub><em>Sponsored* by the Australian Government</em></sub>
</p>
<p align="right">
<sub><em>*: It's not</em></sub>
</p>

## Problem Background

Using `npm/yarn link` can be dissapointing in real life, because our node & bundlers get messed up traversing symlinks; they get stuck and find interdependant packages they were NOT suppose to... 😡

So let's just pretend to `publish` and `install` during local iterations.

That's what these two commands pretend to do:
1. `pack` will prepare your package in a tarball (like publishing) and put it somewhere safe on your machine
2. `link` will unpack that tarball into your other dependants `node_modules/` directory (like a dirty lazy `npm install`)

## Legal

Thanks to the NPM team for making their CLI easy to use.

MIT
