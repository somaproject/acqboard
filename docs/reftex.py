from docutils import nodes
import pickle
from sphinx import directives
import os
from subprocess import Popen
from sphinx.util import ensuredir
from sphinx.util.compat import Directive

class bibcite(nodes.Inline, nodes.TextElement):
    pass

def visit_bibcite_node(self, node):
    pass



class BibCiteDirective(Directive):
    has_content = True

    def run(self):
        b = bibcite('')
        b['citation'] = self.content
        
        return [b]
    

def bibcite_role(role, rawtext, text, lineno, inliner, options={}, content=[]):
    return [bibcite(citation=text)], []

def html_visit_bibcite(self, node):

    self.body.append('[%s]_' % node['citation'])
    raise nodes.SkipNode    

def latex_visit_bibcite(self, node):
    self.body.append("\cite{%s}" % node['citation'])
    raise nodes.SkipNode    

def setup(app):
    app.connect('doctree-resolved', process_nodes)

    app.add_node(bibcite,
                 latex=(latex_visit_bibcite, None), 
                 latexnaked=(latex_visit_bibcite, None), 
                 html=(html_visit_bibcite, None))

    app.add_role('bibcite', bibcite_role)
    

def process_nodes(app, doctree, fromdocname):
    pass

