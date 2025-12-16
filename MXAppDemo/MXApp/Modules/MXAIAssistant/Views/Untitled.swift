//
//  Untitled.swift
//  MXApp
//
//  Created by huafeng on 2025/3/27.
//

class MXAssistantMessageCell: UITableViewCell {
    
    // MARK: - Properties
    private let avatarImageView = UIImageView()
    private let messageContainerView = UIView()
    private let markdownLabel = UITextView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Avatar setup
        avatarImageView.image = UIImage(named: "mx_chatbot_icon")
        avatarImageView.backgroundColor = .clear
        avatarImageView.contentMode = .scaleAspectFit
        
        // Message container setup
        messageContainerView.backgroundColor = MXAppConfiguration.MXWhite.level3
        messageContainerView.layer.cornerRadius = 16
        messageContainerView.clipsToBounds = true
        
        // Markdown label setup
        markdownLabel.isEditable = false
        markdownLabel.isScrollEnabled = false
        markdownLabel.backgroundColor = .clear
        markdownLabel.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        markdownLabel.font = UIFont.systemFont(ofSize: 14)
        markdownLabel.textColor = MXAppConfiguration.MXColor.title
        
        // Add subviews
        contentView.addSubview(avatarImageView)
        contentView.addSubview(messageContainerView)
        messageContainerView.addSubview(markdownLabel)
        
        // Setup constraints
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        markdownLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Avatar constraints
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 42),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // Message container constraints
            messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageContainerView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            messageContainerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60),
            messageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Markdown label constraints
            markdownLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor),
            markdownLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor),
            markdownLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor),
            markdownLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with message: MXChatMessage) {
        // Render markdown content
        renderMarkdown(message.content)
    }
    
    private func renderMarkdown(_ markdownText: String) {
        markdownLabel.attributedText = try? MarkdownParser().parse(markdownText)
    }
}
