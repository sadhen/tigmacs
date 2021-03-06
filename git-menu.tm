<TeXmacs|1.99.5>

<style|<tuple|generic|literate>>

<\body>
  <doc-data|<doc-title|Menu>|<doc-author|<author-data|<author-name|Darcy
  SHEN>>>>

  <section|Module>

  <todo|explain the texmacs module system>

  <\scm-chunk|git-menu.scm|false|true>
    (texmacs-module (utils git git-menu)

    \ \ (:use (utils git git-utils)

    \ \ \ \ \ \ \ \ (utils git git-tmfs)))
  </scm-chunk>

  <section|Menu>

  <todo|what is <scm|(former)>>

  <\scm-chunk|git-menu.scm|true|false>
    (menu-bind git-menu

    \ \ ("Log" (git-show-log))

    \ \ ("Status" (git-show-status))

    \ \ ("Commit" (git-interactive-commit))

    \ \ ---

    \ \ (when (buffer-to-add? (current-buffer))

    \ \ \ \ \ \ \ \ \ \ \ \ ("Add" (git-add (current-buffer))))

    \ \ (when (buffer-to-unadd? (current-buffer))

    \ \ \ \ \ \ \ \ \ \ \ \ ("Undo Add" (git-unadd (current-buffer))))

    \ \ (when (buffer-histed? (current-buffer))

    \ \ \ \ \ \ \ \ ("History" (git-history (current-buffer))))

    \ \ (=\<gtr\> "Compare"

    \ \ \ \ \ \ (when (buffer-tmfs? (current-buffer))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ("With current version"

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (git-compare-with-current
    (current-buffer))))

    \ \ \ \ \ \ (when (buffer-tmfs? (current-buffer))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ("With parent version"

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (git-compare-with-parent
    (current-buffer))))

    \ \ \ \ \ \ (when (and (not (buffer-tmfs? (current-buffer)))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (buffer-has-diff? (current-buffer)))

    \ \ \ \ \ \ \ \ \ \ \ \ ("With the master"

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ (git-compare-with-master
    (current-buffer))))))

    \;

    (menu-bind texmacs-extra-menu

    \ \ (former)

    \ \ (if (git-versioned? (current-buffer))

    \ \ \ \ \ \ (=\<gtr\> "Git"

    \ \ \ \ \ \ \ \ \ \ (link git-menu))))
  </scm-chunk>
</body>

<initial|<\collection>
</collection>>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-2|<tuple|2|?>>
    <associate|chunk-git-menu.scm-1|<tuple|git-menu.scm|?>>
    <associate|chunk-git-menu.scm-2|<tuple|git-menu.scm|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Module>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Menu>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>