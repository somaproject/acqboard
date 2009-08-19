from docutils import nodes
import pickle
from sphinx import directives
import os
from subprocess import Popen
from sphinx.util import ensuredir


from docutils.parsers.rst import directives
from docutils.parsers.rst.directives import images


def testfoo(foo):
    pass


def set_ping_val(foo):
    return float(foo)

def setup(app):
    app.connect('doctree-resolved', process_nodes)

    try:
        images.Figure.option_spec['autoconvert'] = testfoo
        images.Figure.option_spec['pngdpi'] = set_ping_val
    except AttributeError:
        images.figure.options['autoconvert'] = testfoo
        images.figure.options['pngdpi'] = set_ping_val


def inkscapeconv_pdf(srcfilename, destfilename):
    inkscapecmd = "inkscape %(filename)s --export-pdf=%(exportname)s "
    inkscapestr = inkscapecmd % {'filename' : srcfilename,
                                 'exportname' : destfilename}
    p = Popen(inkscapestr, shell=True)
    sts = os.waitpid(p.pid, 0)

def inkscapeconv_png(srcfilename, destfilename, dpi=None):
    
    inkscapecmd = "inkscape %(filename)s --export-png=%(exportname)s "
    if dpi != None:
        inkscapecmd += " --export-dpi=%(exportdpi)f"
        
    inkscapestr = inkscapecmd % {'filename' : srcfilename,
                                 'exportname' : destfilename,
                                 'exportdpi' : dpi}
    p = Popen(inkscapestr, shell=True)
    sts = os.waitpid(p.pid, 0)

def sanitize_pdf_name(fname):
    head, tail = os.path.split(fname)
    newf = tail.replace(".", "_")
    return os.path.join(head, newf)
    
def process_nodes(app, doctree, fromdocname):
    
    
    for node in doctree.traverse(nodes.image):
        if 'autoconvert' in node.attributes:
            
            fname = node.attributes['uri']
            if hasattr(app.builder, 'imgpath'):
                # HTML

                relfn = os.path.join(app.builder.imgpath, fname)
                fn, ext = os.path.splitext(relfn)
                outfn =  os.path.join(app.builder.outdir, "_images", fn + ".png")
                ensuredir(os.path.dirname(outfn))

                dpi = None
                if "pngdpi" in node.attributes:
                    dpi = float(node.attributes['pngdpi'])
                inkscapeconv_png(fname, outfn, dpi)
                #node.attributes['candidates']['application/pdf'] = outfn
                node.attributes['uri'] = outfn

            else:
                # LaTeX
                relfn = fname
                root, ext = os.path.splitext(fname)

                newroot = sanitize_pdf_name(root)
                newroot = newroot + ".pdf"
                outfn = os.path.join(app.builder.outdir, newroot)

                ensuredir(os.path.dirname(outfn))

                print "Target filename would be", outfn
                inkscapeconv_pdf(fname, outfn)

            
                node.attributes['candidates']['application/pdf'] = outfn
                node.attributes['uri'] = outfn
