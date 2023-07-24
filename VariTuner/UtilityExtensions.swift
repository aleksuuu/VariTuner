import SwiftUI

extension Double {
    func centsToRatio() -> Double {
        pow(2, self / 1200)
    }
    func centsToHz(lowerFreq: Double) -> Double {
        lowerFreq * centsToRatio()
    }
}

extension Float {
    func hzToCents(freqToCompare: Float) -> Float? {
        freqToCompare == 0 ? nil : 1200 * log2(self / freqToCompare)
    }
}

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}

extension Scale {
    func contains(_ text: String) -> Bool {
        let lowerCaseText = text.lowercased().trimmingCharacters(in: .whitespaces)
        if name.lowercased().contains(lowerCaseText) || description.lowercased().contains(lowerCaseText) {
            return true
        }
        return false
    }
    var notesString: String {
        var str = ""
        var notesWithoutDegreeZero = notes
        if notes[0].cents == 0 {
            notesWithoutDegreeZero.remove(at: 0)
        }
        for note in notesWithoutDegreeZero {
            if !note.numerator.isEmpty && !note.denominator.isEmpty {
                str += " \(note.numerator)/\(note.denominator)\n"
            } else {
                str += " \(note.cents)\n"
            }
        }
        return str
    }
    var sclString: String {
        """
! \(name).scl
!
\(description)
 \(notes.count - 1)
!
\(notesString)
"""
    }
}

extension String {
    var scale: Scale? {
        let arrayByLine = components(separatedBy: "\n")

        var name = ""
        var description: String? // optional so that whether the description line has been scanned or not can be known even if the description line is empty
        var notes: [Scale.Note] = []
        var numOfNotesHasBeenSet = false
        
        for line in arrayByLine {
            if !numOfNotesHasBeenSet {
                guard notes.isEmpty else { continue }
                guard description == nil else {
                    numOfNotesHasBeenSet = true
                    continue
                }
                // only look for a name and description when description and notes are both not set yet
                if name == "", let n = line.sclName {
                    name = n
                    continue
                } else if line.first != "!" { // description is neither a cent/ratio nor a comment
                    description = line.trimmingCharacters(in: .whitespaces)
                    continue
                }
            } else { // if the number of notes has been set, that means we're in the pitch values section
                let ratioNumbers = line.components(separatedBy: "/")

                if ratioNumbers.count == 2 { // if a ratio exists on this line
                    let num = ratioNumbers[0].trimmingCharacters(in: .whitespaces)
                    let denom = ratioNumbers[1].trimmingCharacters(in: .whitespaces)
                    if let cents = UtilityFuncs.getCentsFromRatio(numerator: num, denominator: denom) {
                        let index = notes.firstIndex(where: { $0.cents > cents }) ?? notes.endIndex
                        let note = Scale.Note(cents: cents, numerator: num, denominator: denom, showCents: false)
                        notes.insert(note, at: index)
                    }
                } else {
                    if let cents = line.sclCents {
                        let index = notes.firstIndex(where: { $0.cents > cents }) ?? notes.endIndex
                        let note = Scale.Note(cents: cents)
                        notes.insert(note, at: index)
                    }
                }
                
            }
        }
        if notes.isEmpty {
            return nil
        } else {
            if notes[0].cents != 0 {
                notes.insert(Scale.Note(cents: 0), at: 0)
            }
            return Scale(name: name, description: description ?? "", notes: notes)
        } 
    }
    
    var sclName: String? {
        let namePattern = #"\!.+\.scl"#
        if let range = range(of: namePattern, options: .regularExpression) {
            return String(self[range].dropFirst().dropLast(4)).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }
    
    var sclCents: Double? {
        Double(trimmingCharacters(in: .whitespaces))
    }
    
    var isSclRatio: Bool {
        return false
    }
}




extension RangeReplaceableCollection where Element: Identifiable {
    subscript(_ element: Element) -> Element {
        get {
            if let index = index(matching: element) {
                return self[index]
            } else {
                return element
            }
        }
        set {
            if let index = index(matching: element) {
                replaceSubrange(index...index, with: [newValue])
            }
        }
    }
}

extension RangeReplaceableCollection where Element: Equatable {
    mutating func remove(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        }
    }
}
