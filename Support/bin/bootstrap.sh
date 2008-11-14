#!/bin/bash

eval tikz=\$$#;

tex="${TMPDIR}/tm-tikz-preview.${TM_PID:-$LOGNAME}.tex"
pdf="${TMPDIR}/tm-tikz-preview.${TM_PID:-$LOGNAME}.pdf";

pre="${TMPDIR}/tm-tikz-preview-preamble.tex";
fmt="${TMPDIR}/tm-tikz-preview-preamble.fmt";

if [[ ! -e "$pre" || ! "$(head -n 1 "$pre")" = "    % b1b0c8241f0dd27bc17aa983cb135179" ]]; then
  cat > "${pre}" <<-'PREAMBLE'
    % b1b0c8241f0dd27bc17aa983cb135179
    \documentclass{article}
    \pagestyle{empty}
    \usepackage{xifthen}
    \usepackage{pgfmath}
    \usepackage{tikz}
    \usetikzlibrary{%
      3d,%
      arrows,%
      automata,%
      backgrounds,%
      calc,%
      calendar,%
      chains,%
      decorations,%
      decorations.footprints,%
      decorations.fractals,%
      decorations.markings,%
      decorations.pathmorphing,%
      decorations.pathreplacing,%
      decorations.shapes,%
      decorations.text,%
      er,%
      fadings,%
      fit,%
      folding,%
      matrix,%
      mindmap,%
      patterns,%
      petri,%
      plothandlers,%
      plotmarks,%
      positioning,%
      scopes,%
      shadows,%
      shapes.arrows,%
      shapes.callouts,%
      shapes,%
      shapes.gates.logic.IEC,%
      shapes.gates.logic.US,%
      shapes.geometric,%
      shapes.misc,%
      shapes.multipart,%
      shapes.symbols,%
      snakes,%
      through,%
      topaths,%
      trees%
    }
    \dump
    \endinput
PREAMBLE
  rm -f "${fmt}"
fi

if [ ! -e "${fmt}" ]; then
  echo "-->Recompiling fmt"
  "${@:1:$#-1}" -halt-on-error -output-format=pdf -output-directory="${TMPDIR}" -ini -jobname="tm-tikz-preview-preamble" \&latex "${pre}"
fi

cat > "${tex}" <<-DOCUMENT
\\begin{document}
$(cat "${tikz}")
\\end{document}
DOCUMENT

oldtexfmt="$TEXFORMATS"
export TEXFORMATS=":$TMPDIR:"
echo "-->Rendering tikzpicture"
"${@:1:$#-1}" -halt-on-error -output-format=pdf -output-directory="${TMPDIR}" \&tm-tikz-preview-preamble "${tex}"; rc=$?;
export TEXFORMATS="$oldtexfmt"

if [ ! $rc = 0 ]; then exit $rc; fi

