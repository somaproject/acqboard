from docutils import nodes
import pickle
from sphinx import directives
import os
from subprocess import Popen
from sphinx.util import ensuredir
from sphinx.util.compat import Directive

class latex(nodes.Inline, nodes.TextElement):
    pass

def visit_latex_node(self, node):
    pass


class LatexDirective(Directive):
    has_content = True

    def run(self):
        b = latex('')
        #b['citation'] = self.content
        
        return [b]
    

def latex_role(role, rawtext, text, lineno, inliner, options={}, content=[]):
    return [latex(latex=text)], []

def html_visit_latex(self, node):

#    self.body.append('<b>%s</b>' % node['latex'])
    raise nodes.SkipNode    

def latex_visit_latex(self, node):
    print 'WE ARE APPENDING', ":%s:" %  node['latex']
    self.body.append("\\%s" % node['latex'])
    raise nodes.SkipNode    

def setup(app):
    app.add_node(latex,
                 latex=(latex_visit_latex, None), 
                 latexnaked=(latex_visit_latex, None), 
                 html=(html_visit_latex, None))

    app.add_role('latex', latex_role)
    

