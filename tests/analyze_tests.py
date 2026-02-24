#!/usr/bin/env python3
"""
Test comparison and analysis tool for DHIR compiler
Analyzes test outputs and generates reports
"""

import os
import sys
import json
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any

class TestAnalyzer:
    def __init__(self, output_dir: str):
        self.output_dir = Path(output_dir)
        self.tests = {}
        
    def analyze_test_file(self, filepath: Path) -> Dict[str, Any]:
        """Analyze a single test output file"""
        info = {
            'name': filepath.stem,
            'size': filepath.stat().st_size,
            'lines': 0,
            'operations': {},
            'dialects': set(),
        }
        
        if not filepath.exists():
            return info
            
        with open(filepath, 'r') as f:
            content = f.read()
            info['lines'] = len(content.splitlines())
            
            # Count operation types
            for line in content.splitlines():
                line = line.strip()
                if line.startswith('"') and '"(' in line:
                    # Extract operation name
                    op_name = line.split('"')[1]
                    info['operations'][op_name] = info['operations'].get(op_name, 0) + 1
                    
                    # Extract dialect
                    if '.' in op_name:
                        dialect = op_name.split('.')[0]
                        info['dialects'].add(dialect)
        
        info['dialects'] = list(info['dialects'])
        return info
    
    def analyze_all_tests(self):
        """Analyze all test outputs"""
        if not self.output_dir.exists():
            print(f"Output directory not found: {self.output_dir}")
            return
        
        # Find all test directories
        for test_dir in self.output_dir.iterdir():
            if not test_dir.is_dir():
                continue
                
            test_name = test_dir.name
            self.tests[test_name] = {}
            
            # Analyze each pass output
            for mlir_file in sorted(test_dir.glob("*.mlir")):
                pass_name = mlir_file.stem
                self.tests[test_name][pass_name] = self.analyze_test_file(mlir_file)
    
    def generate_report(self, output_file: str = None):
        """Generate analysis report"""
        report = []
        report.append("=" * 80)
        report.append("DHIR Compiler Test Analysis Report")
        report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("=" * 80)
        report.append("")
        
        if not self.tests:
            report.append("No test data found.")
            report_text = "\n".join(report)
            
            if output_file:
                with open(output_file, 'w') as f:
                    f.write(report_text)
            else:
                print(report_text)
            return
        
        # Per-test analysis
        for test_name, passes in sorted(self.tests.items()):
            report.append(f"Test: {test_name}")
            report.append("-" * 80)
            
            for pass_name, info in sorted(passes.items()):
                report.append(f"  {pass_name}:")
                report.append(f"    Lines: {info['lines']}")
                report.append(f"    Size: {info['size']} bytes")
                report.append(f"    Dialects: {', '.join(info['dialects'])}")
                
                if info['operations']:
                    top_ops = sorted(info['operations'].items(), 
                                   key=lambda x: x[1], 
                                   reverse=True)[:5]
                    report.append(f"    Top operations:")
                    for op, count in top_ops:
                        report.append(f"      {op}: {count}")
                
                report.append("")
            
            report.append("")
        
        # Summary
        report.append("=" * 80)
        report.append("Summary")
        report.append("=" * 80)
        report.append(f"Total tests analyzed: {len(self.tests)}")
        
        # Count dialects used across all tests
        all_dialects = set()
        for test_data in self.tests.values():
            for pass_data in test_data.values():
                all_dialects.update(pass_data['dialects'])
        
        report.append(f"Dialects used: {', '.join(sorted(all_dialects))}")
        
        report_text = "\n".join(report)
        
        if output_file:
            with open(output_file, 'w') as f:
                f.write(report_text)
            print(f"Report written to: {output_file}")
        else:
            print(report_text)
    
    def export_json(self, output_file: str):
        """Export analysis data as JSON"""
        data = {
            'timestamp': datetime.now().isoformat(),
            'tests': self.tests
        }
        
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=2, default=str)
        
        print(f"JSON data exported to: {output_file}")

def main():
    parser = argparse.ArgumentParser(
        description='Analyze DHIR compiler test outputs')
    parser.add_argument('output_dir', 
                       help='Test output directory (e.g., build/test_output)')
    parser.add_argument('--report', '-r', 
                       help='Output report file (default: stdout)')
    parser.add_argument('--json', '-j', 
                       help='Export JSON data to file')
    
    args = parser.parse_args()
    
    analyzer = TestAnalyzer(args.output_dir)
    analyzer.analyze_all_tests()
    analyzer.generate_report(args.report)
    
    if args.json:
        analyzer.export_json(args.json)

if __name__ == '__main__':
    main()