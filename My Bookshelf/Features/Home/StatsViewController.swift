//
//  StatsViewController.swift
//  My Bookshelf
//
//  Created by Dashdemirli Enver on 16.11.25.
//

import UIKit

final class StatsViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Statistics"
        view.backgroundColor = .appBackground
        setupUI()
        loadStats()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func loadStats() {
        let calculator = StatsCalculator.shared
        
        // Total Books Read
        let totalCard = createStatCard(
            title: "Total Books Read",
            value: "\(calculator.totalReadBooks)",
            icon: "book.fill"
        )
        contentStack.addArrangedSubview(totalCard)
        
        // Top Genres
        let topGenres = calculator.topGenres(limit: 5)
        if !topGenres.isEmpty {
            let genresCard = createGenresCard(genres: topGenres)
            contentStack.addArrangedSubview(genresCard)
        } else {
            let emptyCard = createStatCard(
                title: "Top Genres",
                value: "No tracked genres",
                icon: "tag.fill"
            )
            contentStack.addArrangedSubview(emptyCard)
        }
        
        // Monthly Counts (if available)
        let monthlyCounts = calculator.monthlyCounts
        if monthlyCounts.isEmpty {
            let monthlyCard = createMonthlyCard(counts: monthlyCounts)
            contentStack.addArrangedSubview(monthlyCard)
        }
    }
    
    private func createStatCard(title: String, value: String, icon: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .card
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 120),
            
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 30),
            iconView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            valueLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
        ])
        
        return card
    }
    
    private func createGenresCard(genres: [(genre: String, count: Int)]) -> UIView {
        let card = UIView()
        card.backgroundColor = .card
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Top Genres"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        
        var previousView: UIView = titleLabel
        for (index, genre) in genres.enumerated() {
            let genreView = createGenreRow(genre: genre.genre, count: genre.count, rank: index + 1)
            card.addSubview(genreView)
            
            NSLayoutConstraint.activate([
                genreView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: index == 0 ? 16 : 12),
                genreView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
                genreView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20)
            ])
            
            previousView = genreView
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            previousView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        return card
    }
    
    private func createGenreRow(genre: String, count: Int, rank: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let rankLabel = UILabel()
        rankLabel.text = "\(rank)."
        rankLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        rankLabel.textColor = .label
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let genreLabel = UILabel()
        genreLabel.text = genre.capitalized
        genreLabel.font = .systemFont(ofSize: 16)
        genreLabel.textColor = .label
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = .systemFont(ofSize: 16, weight: .medium)
        countLabel.textColor = .secondaryLabel
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(rankLabel)
        container.addSubview(genreLabel)
        container.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 24),
            
            rankLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            rankLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 30),
            
            genreLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 8),
            genreLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            countLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createMonthlyCard(counts: [Int: Int]) -> UIView {
        let card = UIView()
        card.backgroundColor = .card
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Monthly Reading"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        // TODO: Add chart visualization here
        
        return card
    }
}
