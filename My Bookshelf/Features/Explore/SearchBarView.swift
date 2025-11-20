//
//  SearchBarView.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 20.11.25.
//

import UIKit

protocol SearchBarViewDelegate: AnyObject {
    func searchBarView(_ searchBarView: SearchBarView, didSubmit query: String)
}

final class SearchBarView: UIView {

    weak var delegate: SearchBarViewDelegate?

    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = .secondaryLabel
        return iv
    }()

    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search books, authors, ISBN..."
        tf.returnKeyType = .search
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 10
        layer.masksToBounds = true

        let stack = UIStackView(arrangedSubviews: [iconView, textField])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

extension SearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !text.isEmpty {
            delegate?.searchBarView(self, didSubmit: text)
        }
        textField.resignFirstResponder()
        return true
    }
}
