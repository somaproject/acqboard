from docutils import nodes
import pickle
from sphinx import directives
import os
from subprocess import Popen
from sphinx.util import ensuredir


from docutils.parsers.rst import directives
from docutils.parsers.rst.directives import images


def testfoo(foo):
    print "Testfoo called", foo

def setup(app):
    app.connect('doctree-resolved', process_nodes)

    try:
        images.Figure.option_spec['autoconvert'] = testfoo
    except AttributeError:
        images.figure.options['autoconvert'] = testfoo


def inkscapeconv_pdf(srcfilename, destfilename):
    inkscapecmd = "inkscape %(filename)s --export-pdf=%(exportname)s "
    inkscapestr = inkscapecmd % {'filename' : srcfilename,
                                 'exportname' : destfilename}
    print "calling inkscape with cmd", inkscapestr
    p = Popen(inkscapestr, shell=True)
    sts = os.waitpid(p.pid, 0)

def inkscapeconv_png(srcfilename, destfilename):
    inkscapecmd = "inkscape %(filename)s --export-png=%(exportname)s "
    inkscapestr = inkscapecmd % {'filename' : srcfilename,
                                 'exportname' : destfilename}
    print "calling inkscape with cmd", inkscapestr
    p = Popen(inkscapestr, shell=True)
    sts = os.waitpid(p.pid, 0)

def sanitize_pdf_name(fname):
    head, tail = os.path.split(fname)
    newf = tail.replace(".", "_")
    return os.path.join(head, newf)
    
def process_nodes(app, doctree, fromdocname):
    
    
    for node in doctree.traverse(nodes.image):
        if 'autoconvert' in node.attributes:
            print "We should attempt to autoconvert", node.attributes['uri']
            print node.attributes['candidates']
            
            fname = node.attributes['uri']
            if hasattr(app.builder, 'imgpath'):
                # HTML

                relfn = os.path.join(app.builder.imgpath, fname)
                fn, ext = os.path.splitext(relfn)
                outfn =  os.path.join(app.builder.outdir, "_images", fn + ".png")
                print "The filename is", outfn
                ensuredir(os.path.dirname(outfn))

                inkscapeconv_png(fname, outfn)
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
