
import pylightxl as xl
import sys
from pathlib import Path


class Parser:
    def __init__(self, file_name, n_col=1, cdn_col=2, twc_col=3):
        self._jnl = []
        self._jns = {}
        self._cdn = {}
        self._twc = {}

        # custom column numbering (excel indexes at 1)
        self._nc = int(n_col) -1
        self._cc = int(cdn_col) -1 
        self._tc = int(twc_col) - 1

        self.parse_file(file_name)

    def parse_file(self, sheet):
        self._db = xl.readxl(fn=sheet)
        self._ws = self._db.ws(self._db.ws_names[0]) # takes the first worksheet

        # journal overall list
        for row_n, row in enumerate(self._ws.rows):
            # skip the title row
            if row_n == 0:
                continue 
            self._jnl.append({ "name": row[self._nc] , "coden": row[self._cc], "two_letter_code": row[self._tc] })

        # sub lists
        for idx, jnl in enumerate(self._jnl):
            self._jns[jnl["name"].lower()] = idx
            self._cdn[jnl["coden"].lower()] = idx
            self._twc[jnl["two_letter_code"].lower()] = idx


    def write(self):
        print()
    
    def write_js_obj(self):
        print("Copy contents below: \n")
        print("const journals = " + str(self._jnl) + ";\n")
        print("const journal_names = " + str(self._jns) + ";\n")
        print("const codens = " + str(self._cdn) + ";\n")
        print("const two_letter_codes = " + str(self._twc) + ";\n")
        print("\n")

if __name__ == "__main__":
    if len(sys.argv) != 2 and len(sys.argv) != 5:
        sys.exit("Requires launch arguments - run as 'convert-xlsx.py [input]')")
    
    if len(sys.argv) == 5:
        parser = Parser(sys.argv[1], n_col = sys.argv[2], cdn_col =sys.argv[3], twc_col =sys.argv[4])
    else:
        parser = Parser(sys.argv[1])
    parser.write_js_obj()

