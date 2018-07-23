import foobar
import lolbeans
import bigbutts

from foo import bar
from lol import beans
from big import butts


def foobar(args):
    return 1

def lolbeans():
    print("hammer time!")

def its_hammer_time():
    """something something

    more info: darkside
    """
    print("hammer time!")

class Ass(object):
    """this is a description

    Args:
        some stuff: -----
    """

    def __init__(self, left, right):
        self.left = left
        self.right = right

    @classmethod
    def from_left(cls, left):
        return cls(left, 'THIS IS RIGHT')

    def kick(self):
        return 'pow!'

    def math(*args, multiplier=2,
             divider=5):
        return (sum(args) * 2) / divider
