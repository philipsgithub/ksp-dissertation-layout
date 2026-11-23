# ======================================================================
# latexmkrc for XeLaTeX + Biber + Makeglossaries (Draft Optimized)
# ======================================================================

# Use the TeX tools installed next to this latexmk, so builds also work when
# TeX Live is reached through a shell alias and is not on PATH.
my $tex_bin = File::Basename::dirname($0);
$ENV{PATH} = "$tex_bin:$ENV{PATH}" if -x "$tex_bin/xelatex";

# Increase max runs from the default 5 to 8
$max_repeat = 8;

# Desktop notifications are optional and must not disturb console builds.
$compiling_cmd = "command -v notify-send >/dev/null && notify-send -t 15000 'LaTeX Build' 'Compilation started...' 2>/dev/null || true";
$success_cmd = 'internal build_success';
sub build_success {
    out2_sync();
    system("command -v notify-send >/dev/null && notify-send 'latexmk: Success' 'Build complete!' -t 1000 2>/dev/null || true");
    return 0;
}
$failure_cmd = "command -v notify-send >/dev/null && notify-send 'latexmk: Failed' 'Check the logs.' -u critical 2>/dev/null || true";

# Tell latexmk to ignore CreationDate, ModDate, and ID metadata when hashing PDFs
$hash_calc_ignore_pattern{'pdf'} = '(/(CreationDate|ModDate|ID) |<xmp(:CreateDate|:ModifyDate|:MetadataDate|MM:InstanceID)|<rdf:li)';

# --- 1. The "-no-pdf" Orchestrator ---
# Mode 5 tells latexmk: "Run xelatex -no-pdf in a loop until the .xdv 
# stabilizes. ONLY run xdvipdfmx at the very end."
$pdf_mode = 5;

# --- 2. XeLaTeX Compiler Flags ---
# Passed through to every run. --shell-escape is kept for TikZ externalization.
$xelatex = 'xelatex -synctex=1 -interaction=nonstopmode --shell-escape %O %P 1>/dev/null';

# --- 3. xdvipdfmx Optimization ---
# -z 0 turns off compression for a massive speedup on the final PDF assembly.
$xdvipdfmx = 'xdvipdfmx -z 0 -o %D %O %S 1>/dev/null';

# --- 4. Bibliography ---
$biber = 'biber %O %S 1>/dev/null';

# --- 5. Makeglossaries Orchestration ---
# Tell latexmk to watch for changes to glossary/acronym files and run 
# makeglossaries automatically in the middle of the compilation loop.
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
    my ($base_name, $path) = fileparse( $_[0] );
    my @cmd = ('makeglossaries');
    push @cmd, '-q' if $silent;
    push @cmd, '-d', $path, $base_name;
    return system(@cmd);
}

# Ensure latexmk cleans up all the messy glossary auxiliary files 
# when you run `latexmk -c`
push @generated_exts, 'glo', 'gls', 'glg', 'acn', 'acr', 'alg', 'ist';

# --- 6. Build Directory ---
# Build files stay in .build. The PDF and its SyncTeX file are copied to the
# project root, so editor jumps also work with the root PDF.
$out_dir = '.build';
$out2_dir = '.';
@out2_exts = ('pdf', 'synctex.gz');

# latexmk only copies files created in the current run to $out2_dir. After each
# successful build, also copy these files if they are missing or outdated there.
sub out2_sync {
    require File::Copy;
    foreach my $ext (@out2_exts) {
        my $from = "$out_dir/$root_filename.$ext";
        my $to   = "$out2_dir/$root_filename.$ext";
        next unless -e $from;
        next if -e $to && -s $to == -s $from && (stat $to)[9] >= (stat $from)[9];
        File::Copy::copy($from, $to) or warn "out2_sync: copying $from to $to failed: $!\n";
    }
    return 0;
}

# --- 7. Index ---
# imakeidx would run makeindex from the project root and miss .build/Diss.idx,
# so latexmk runs it instead. The style path is absolute because latexmk changes
# into the build directory for makeindex.
$pre_tex_code = '\PassOptionsToPackage{noautomatic}{imakeidx}';
$makeindex = "makeindex -g -s '" . Cwd::getcwd() . "/preambel/IndexStyle.tex' %O -o %D %S";
