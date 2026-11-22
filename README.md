# KSP Dissertation Layout (Fork)

This is a fork of the [KIT Scientific Publishing (KSP) dissertation template](https://gitlab.cc-asp.fraunhofer.de/kit-ksp/dissertation-template) by Michael Grinberg with an updated A4 XeLaTeX layout.
It is an independent fork, not an official template of KIT, KSP or Fraunhofer.

The `master` branch matches the original template, and `layout_updates` contains the layout changes.

## Layout

- A4, 12pt, 160mm text width, and a two-sided layout
- Source Sans Pro headings and JetBrains Mono code listings
- IEEE-style numeric citations with separate publication, patent and thesis lists
- Clickable links between headings and the table of contents
- Digital and print output from one source

## Build

Install a TeX distribution with XeLaTeX, Biber, makeglossaries and latexmk, then run:

```bash
latexmk Diss.tex
```

For the print version, set `printVersion` to `true` in `preambel/AlleSchalter.tex`.
It uses a 5mm binding offset, 22.5mm margins and black links.

The example chapters explain the template in German. Switches are in `preambel/AlleSchalter.tex`, and title data is in `preambel/AlleAngaben.tex`.

## License

The template is available under the MIT License, see `LICENSE`.
Bundled fonts keep their own licenses, see `fonts/licenses/README.md`.
