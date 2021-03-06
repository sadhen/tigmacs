<TeXmacs|1.99.5>

<style|<tuple|generic|literate>>

<\body>
  <strong|><doc-data|<doc-title|Utils for
  Git>|<doc-author|<author-data|<author-name|Darcy SHEN>>>>

  <section|Module>

  <\scm-chunk|git-utils.scm|false|true>
    (texmacs-module (utils git git-utils))
  </scm-chunk>

  <section|Constants>

  <verbatim|gitroot> is a variable that holds the git root of the current
  buffer, initially set to <verbatim|/>. Assuming <verbatim|/.git> is not
  exist, we can use <scm|(!= gitroot "/")> to check if the current buffer is
  under a git-versioned directory.

  <\scm-chunk|git-utils.scm|true|true>
    (define callgit "git")

    (define NR_LOG_OPTION " -1000 ")

    \;

    (define gitroot "/")
  </scm-chunk>

  <section|Subroutines>

  <\scm-chunk|git-utils.scm|true|true>
    (define (delete-tail-newline a-str)

    \ \ (if (string-ends? a-str "\\n")

    \ \ \ \ \ \ (delete-tail-newline (string-drop-right a-str 1))

    \ \ \ \ \ \ a-str))
  </scm-chunk>

  <subsection|buffer>

  <\scm-chunk|git-utils.scm|true|true>
    (tm-define (git-root dir)

    \ \ (let* ((git-dir (url-append dir ".git"))

    \ \ \ \ \ \ \ \ \ (pdir (url-expand (url-append dir ".."))))

    \ \ \ \ (cond ((url-directory? git-dir)

    \ \ \ \ \ \ \ \ \ \ \ (string-replace (url-\<gtr\>string dir) "\\\\"
    "/"))

    \ \ \ \ \ \ \ \ \ \ ((== pdir dir) "/")

    \ \ \ \ \ \ \ \ \ \ (else (git-root pdir)))))

    \;

    (tm-define (git-versioned? name)

    \ \ (when (not (buffer-tmfs? name))

    \ \ \ \ (set! gitroot

    \ \ \ \ \ \ \ \ \ \ (git-root (if (url-directory? name)

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ name

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (url-head name))))

    \ \ \ \ (set! callgit

    \ \ \ \ \ \ \ \ \ \ (string-append "git --work-tree=" gitroot

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ " --git-dir=" gitroot
    "/.git")))

    \ \ (!= gitroot "/"))

    \;

    (tm-define (buffer-status name)

    \ \ (let* ((name-s (url-\<gtr\>string name))

    \ \ \ \ \ \ \ \ \ (cmd (string-append callgit " status --porcelain "
    name-s))

    \ \ \ \ \ \ \ \ \ (ret (eval-system cmd)))

    \ \ \ \ (cond ((\<gtr\> (string-length ret) 3) (string-take ret 2))

    \ \ \ \ \ \ \ \ \ \ ((file-exists? name-s) " \ ")

    \ \ \ \ \ \ \ \ \ \ (else ""))))

    \;

    (tm-define (buffer-to-unadd? name)

    \ \ (with ret (buffer-status name)

    \ \ \ \ \ \ \ \ (or (== ret "A ")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret "M ")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret "MM")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret "AM"))))\ 

    \;

    (tm-define (buffer-to-add? name)

    \ \ (with ret (buffer-status name)

    \ \ \ \ \ \ \ \ (or (== ret "??")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret " M")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret "MM")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret "AM"))))

    \;

    (tm-define (buffer-histed? name)

    \ \ (with ret (buffer-status name)

    \ \ \ \ \ \ \ \ (or (== ret "M ")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret "MM")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret " M")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret " \ "))))

    \;

    (tm-define (buffer-has-diff? name)

    \ \ (with ret (buffer-status name)

    \ \ \ \ \ \ \ \ (or (== ret "M ")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret "MM")

    \ \ \ \ \ \ \ \ \ \ \ \ (== ret " M"))))

    \;

    (tm-define (buffer-tmfs? name)

    \ \ (string-starts? (url-\<gtr\>string name)

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "tmfs"))
  </scm-chunk>

  <section|Git Operations>

  <subsection|git add>

  <shell|git add $filename>

  <todo|The concat of the cmd should be a subroutine and should not directly
  call string-append>

  <\scm-chunk|git-utils.scm|true|true>
    (tm-define (git-add name)

    \ \ (let* ((name-s (url-\<gtr\>string name))

    \ \ \ \ \ \ \ \ \ (cmd (string-append callgit " add " name-s))

    \ \ \ \ \ \ \ \ \ (ret (eval-system cmd)))

    \ \ \ \ (set-message cmd "The file is added")))
  </scm-chunk>

  <subsection|git unadd>

  <shell|git reset HEAD $filename>

  <\scm-chunk|git-utils.scm|true|true>
    (tm-define (git-unadd name)

    \ \ (display name)

    \ \ (let* ((name-s (url-\<gtr\>string name))

    \ \ \ \ \ \ \ \ \ (cmd (string-append callgit " reset HEAD " name-s))

    \ \ \ \ \ \ \ \ \ (ret (eval-system cmd)))

    \ \ \ \ (set-message cmd "The file is unadded.")

    \ \ \ \ (display cmd)))
  </scm-chunk>

  <subsection|git log>

  <\scm-chunk|git-utils.scm|true|true>
    (tm-define (buffer-log name)

    \ \ (let* ((name1 (string-replace (url-\<gtr\>string name) "\\\\" "/"))

    \ \ \ \ \ \ \ \ \ (sub (string-append gitroot "/"))

    \ \ \ \ \ \ \ \ \ (name-s (string-replace name1 sub ""))

    \ \ \ \ \ \ \ \ \ (cmd (string-append

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ callgit " log --pretty=%ai%n%an%n%s%n%H%n"

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ NR_LOG_OPTION

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ name1))

    \ \ \ \ \ \ \ \ \ (ret1 (eval-system cmd))

    \ \ \ \ \ \ \ \ \ (ret2 (string-decompose ret1 "\\n\\n")))

    \ \ \ \ (define (string-\<gtr\>commit-file str)

    \ \ \ \ \ \ (string-\<gtr\>commit str name-s))

    \ \ \ \ (and (\<gtr\> (length ret2) 0)

    \ \ \ \ \ \ \ \ \ (string-null? (cAr ret2))

    \ \ \ \ \ \ \ \ \ (map string-\<gtr\>commit-file (cDr ret2)))))

    \;

    (tm-define (git-log)

    \ \ (let* ((cmd (string-append

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ callgit

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ " log --pretty=%ai%n%an%n%s%n%H%n"

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ NR_LOG_OPTION))

    \ \ \ \ \ \ \ \ \ (ret1 (eval-system cmd))

    \ \ \ \ \ \ \ \ \ (ret2 (string-decompose ret1 "\\n\\n")))

    \ \ \ \ (define (string-\<gtr\>commit-diff str)

    \ \ \ \ \ \ (string-\<gtr\>commit str ""))

    \ \ \ \ (and (\<gtr\> (length ret2) 0)

    \ \ \ \ \ \ \ \ \ (string-null? (cAr ret2))

    \ \ \ \ \ \ \ \ \ (map string-\<gtr\>commit-diff (cDr ret2)))))
  </scm-chunk>

  <subsection|git diff>

  <\scm-chunk|git-utils.scm|true|true>
    (tm-define (git-compare-with-current name)

    \ \ (let* ((name-s (url-\<gtr\>string name))

    \ \ \ \ \ \ \ \ \ (file-r (cAr (string-split name-s #\\\|)))

    \ \ \ \ \ \ \ \ \ (file (string-append gitroot "/" file-r)))

    \ \ \ \ (switch-to-buffer (string-\<gtr\>url file))

    \ \ \ \ (compare-with-older name)))

    \;

    (tm-define (git-compare-with-parent name)

    \ \ (let* ((name-s (tmfs-cdr (tmfs-cdr (url-\<gtr\>tmfs-string name))))

    \ \ \ \ \ \ \ \ \ (hash (first (string-split name-s #\\\|)))

    \ \ \ \ \ \ \ \ \ (file (second (string-split name-s #\\\|)))

    \ \ \ \ \ \ \ \ \ (file-buffer-s (tmfs-url-commit (git-commit-file-parent
    file hash)

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "\|"
    file))

    \ \ \ \ \ \ \ \ \ (parent (string-\<gtr\>url file-buffer-s)))

    \ \ \ \ (if (== name parent)

    \ \ \ \ \ \ \ \ ;; FIXME: should prompt a dialog

    \ \ \ \ \ \ \ \ (set-message "No parent" "No parent")

    \ \ \ \ \ \ \ \ (compare-with-older parent))))

    \;

    (tm-define (git-compare-with-master name)

    \ \ (let* ((name-s (string-replace (url-\<gtr\>string name)

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (string-append
    gitroot "/")

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "\|"))

    \ \ \ \ \ \ \ \ \ (file-buffer-s (tmfs-url-commit (git-commit-master)

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ name-s))

    \ \ \ \ \ \ \ \ \ (master (string-\<gtr\>url file-buffer-s)))

    \ \ \ \ (compare-with-older master)))
  </scm-chunk>

  <subsection|git status>

  <\scm-chunk|git-utils.scm|true|true>
    (tm-define (git-status)

    \ \ (let* ((cmd (string-append callgit " status --porcelain"))

    \ \ \ \ \ \ \ \ \ (ret1 (eval-system cmd))

    \ \ \ \ \ \ \ \ \ (ret2 (string-split ret1 #\\nl)))

    \ \ \ \ (define (convert name)

    \ \ \ \ \ \ (let* ((status (string-take name 2))

    \ \ \ \ \ \ \ \ \ \ \ \ \ (filename (string-drop name 3))

    \ \ \ \ \ \ \ \ \ \ \ \ \ (file (if (or (string-starts? status "A")

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (string-starts?
    status "?"))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ filename

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ($link
    (tmfs-url-git_history (url-\<gtr\>tmfs-string\ 

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (string-append\ 

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ gitroot
    "/" filename)))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (utf8-\<gtr\>cork
    filename)))))

    \ \ \ \ \ \ \ \ (list status file)))

    \ \ \ \ (and (\<gtr\> (length ret2) 0)

    \ \ \ \ \ \ \ \ \ (string-null? (cAr ret2))

    \ \ \ \ \ \ \ \ \ (map convert (cDr ret2)))))
  </scm-chunk>

  <subsection|git commit>

  <\scm-chunk|git-utils.scm|true|true>
    (tm-define (git-interactive-commit)

    \ \ (:interactive #t)

    \ \ (git-show-status)

    \ \ (interactive (lambda (message) (git-commit message))))

    \;

    (tm-define (git-commit message)

    \ \ (let* ((cmd (string-append

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ callgit " commit -m \\"" message "\\""))

    \ \ \ \ \ \ \ \ \ (ret (eval-system cmd)))

    \ \ \ \ ;; (display ret)

    \ \ \ \ (set-message (string-append callgit " commit") message))

    \ \ (git-show-status))
  </scm-chunk>

  <subsection|Low Level Git Operations>

  <\scm-chunk|git-utils.scm|true|false>
    (tm-define (git-show object)

    \ \ (let* ((cmd (string-append callgit " show " object))

    \ \ \ \ \ \ \ \ \ (ret (eval-system cmd)))

    \ \ \ \ ;; (display* "\\n" cmd "\\n" ret "\\n")

    \ \ \ \ ret))

    \;

    (tm-define (git-commit-message hash)

    \ \ (let* ((cmd (string-append callgit " log -1 " hash))

    \ \ \ \ \ \ \ \ \ (ret (eval-system cmd)))

    \ \ \ \ (string-split ret #\\nl)))

    \;

    (tm-define (git-commit-parent hash)

    \ \ (let* ((cmd (string-append

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ callgit " log -2 --pretty=%H " hash))

    \ \ \ \ \ \ \ \ \ (ret1 (eval-system cmd))

    \ \ \ \ \ \ \ \ \ (ret2 (delete-tail-newline ret1))

    \ \ \ \ \ \ \ \ \ (ret3 (string-split ret2 #\\nl))

    \ \ \ \ \ \ \ \ \ (ret4 (cAr ret3)))

    \ \ \ \ ret4))

    \;

    (tm-define (git-commit-file-parent file hash)

    \ \ (let* ((cmd (string-append

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ callgit " log --pretty=%H "

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ gitroot "/" file))

    \ \ \ \ \ \ \ \ \ (ret (eval-system cmd))

    \ \ \ \ \ \ \ \ \ (ret2 (string-decompose

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ret (string-append hash "\\n"))))

    \ \ \ \ ;; (display ret2)

    \ \ \ \ (if (== (length ret2) 1)

    \ \ \ \ \ \ \ \ hash

    \ \ \ \ \ \ \ \ (string-take (second ret2) 40))))

    \;

    (tm-define (git-commit-master)

    \ \ (let* ((cmd (string-append callgit " log -1 --pretty=%H"))

    \ \ \ \ \ \ \ \ \ (ret (eval-system cmd)))

    \ \ \ \ (delete-tail-newline ret)))

    \;

    (tm-define (git-commit-diff parent hash)

    \ \ (let* ((cmd (if (== parent hash)

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (string-append

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ callgit " show " hash

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ " --numstat --pretty=oneline")

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (string-append

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ callgit " diff --numstat "

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ parent " " hash)))

    \ \ \ \ \ \ \ \ \ (ret (eval-system cmd))

    \ \ \ \ \ \ \ \ \ (ret2 (if (== parent hash)

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (cdr (string-split ret #\\nl))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (string-split ret #\\nl))))

    \ \ \ \ (define (convert body)

    \ \ \ \ \ \ (let* ((alist (string-split body #\\ht)))

    \ \ \ \ \ \ \ \ (if (== (first alist) "-")

    \ \ \ \ \ \ \ \ \ \ \ \ (list 0 0 (utf8-\<gtr\>cork (third alist))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (string-length (third alist)))

    \ \ \ \ \ \ \ \ \ \ \ \ (list (string-\<gtr\>number (first alist))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (string-\<gtr\>number (second alist))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ($link (tmfs-url-commit hash "\|"
    (third alist))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (utf8-\<gtr\>cork
    (third alist)))

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ (string-length (third alist))))))

    \ \ \ \ (and (\<gtr\> (length ret2) 0)

    \ \ \ \ \ \ \ \ \ (string-null? (cAr ret2))

    \ \ \ \ \ \ \ \ \ (map convert (cDr ret2)))))
  </scm-chunk>

  \;
</body>

<initial|<\collection>
</collection>>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-10|<tuple|4.5|?>>
    <associate|auto-11|<tuple|4.6|?>>
    <associate|auto-12|<tuple|4.7|?>>
    <associate|auto-2|<tuple|2|?>>
    <associate|auto-3|<tuple|3|?>>
    <associate|auto-4|<tuple|3.1|?>>
    <associate|auto-5|<tuple|4|?>>
    <associate|auto-6|<tuple|4.1|?>>
    <associate|auto-7|<tuple|4.2|?>>
    <associate|auto-8|<tuple|4.3|?>>
    <associate|auto-9|<tuple|4.4|?>>
    <associate|chunk-git-utils.scm-1|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-10|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-11|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-2|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-3|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-4|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-5|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-6|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-7|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-8|<tuple|git-utils.scm|?>>
    <associate|chunk-git-utils.scm-9|<tuple|git-utils.scm|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Module>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Constants>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3<space|2spc>Subroutines>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3><vspace|0.5fn>

      <with|par-left|<quote|1tab>|3.1<space|2spc>buffer
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|4<space|2spc>Git
      Operations> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5><vspace|0.5fn>

      <with|par-left|<quote|1tab>|4.1<space|2spc>git add
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>

      <with|par-left|<quote|1tab>|4.2<space|2spc>git unadd
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7>>

      <with|par-left|<quote|1tab>|4.3<space|2spc>git log
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8>>

      <with|par-left|<quote|1tab>|4.4<space|2spc>git diff
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-9>>

      <with|par-left|<quote|1tab>|4.5<space|2spc>git status
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-10>>

      <with|par-left|<quote|1tab>|4.6<space|2spc>git commit
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-11>>

      <with|par-left|<quote|1tab>|4.7<space|2spc>Low Level Git Operations
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-12>>
    </associate>
  </collection>
</auxiliary>