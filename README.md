# Extended-Shader-Plugin

Hello! This is demo(?) Plugin for adding preprocessors to shaders in Godot 3.1
It currently supports the following directives.
* #define (There's a bug where nesting brackets inside a function macro can't work.)
* #undef
* #ifdef
* #ifndef
* #if
* #elif
* #else
* #endif
* #include

You need to enable the plugin in the `Project Settings` first and close and open the project before you can use it.

## Making an extended shader

To make an extended shader create a new resource via the inspector or the file system. Search for `Extended Shader` and create it.

## include preprocessors

`#include` can be used to add code from shader fragments. These fragments must be extended shader as well. A common practice when using preprocessor directives is to guard your shader fragments in a `#ifndef` as seen the demo. This way you can include them multiple times without duplicating code. `#includes` can be nested too.

## variable macros

The extended shader has a `defines` dictionary that allows you to prepend macros to the shader. The keys __must__ be a string. Also, these variables will not be used by shader fragments that are used in `#includes`.

## The editor

The editor is very basic and has very little features compared to the built-in shader editor. If you want to know what error occured in the shader, you'll have to look in the output panel, or the console to get a general idea of where the error is. Also note that if you use `#if`, `#ifdef` or `#ifndef` statements, code that gets omitted by them will not be accounted for, and so it's a good idea to test each branch for errors.

## One more thing

This project is more of a proof of concept. While it _could_ be used in production, I never tested it in exporting projects. I also will most likely won't update it too often or at all, so if you find an issue, it's probably best that you fix it yourself. I may still take pull requests.
